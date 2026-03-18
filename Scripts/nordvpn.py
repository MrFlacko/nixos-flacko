#!/usr/bin/env nix-shell
#!nix-shell --pure -i python3 -p gobject-introspection gtk3 'python3.withPackages (ps: with ps; [ pygobject3 ])'

import os
import re
import shlex
import shutil
import subprocess
import threading
import time

os.environ.pop("GTK_MODULES", None)

_saved_stderr = os.dup(2)
_devnull = os.open(os.devnull, os.O_WRONLY)
os.dup2(_devnull, 2)
os.close(_devnull)

import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, GLib, Gdk

Gtk.init([])

os.dup2(_saved_stderr, 2)
os.close(_saved_stderr)

TITLE = "NordVPN Quick Connect"
COUNTRIES_FILE = "/var/lib/wgnord/countries.txt"
DEFAULT_COUNTRY = "Australia"
STATUS_REFRESH_MS = 2000

ANSI_RE = re.compile(r"\x1B\[[0-?]*[ -/]*[@-~]")


class NordVPNWindow(Gtk.Window):
    def __init__(self):
        super().__init__(title=TITLE)
        self.set_default_size(920, 700)
        self.set_border_width(16)

        self.selected_country = DEFAULT_COUNTRY
        self.country_rows = []
        self.info_fields = {}

        settings = Gtk.Settings.get_default()
        if settings:
            settings.set_property("gtk-application-prefer-dark-theme", True)

        self.root_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14)
        self.add(self.root_box)

        self.apply_css()
        self.build_header()
        self.build_controls()
        self.build_debug_panel()

        self.countries = self.load_countries()
        self.populate_country_dropdown(self.countries, DEFAULT_COUNTRY)

        self.set_busy(False)
        self.refresh_status()
        GLib.timeout_add(STATUS_REFRESH_MS, self.periodic_refresh)

    def apply_css(self):
        css = b"""
        window {
            background: #1e1f22;
        }

        .title-label {
            font-size: 22px;
            font-weight: 700;
            color: #f2f2f2;
        }

        .subtitle-label {
            color: #b8bec9;
        }

        .section-label {
            font-weight: 700;
            color: #e8eaed;
        }

        button {
            background: #2b2f36;
            color: #f2f2f2;
            border-radius: 10px;
            border: 1px solid #495264;
            padding: 10px 14px;
        }

        button:hover {
            background: #343942;
        }

        button.suggested-action {
            background: #2d5a88;
            color: white;
        }

        .country-button {
            background: #343942;
            color: #f2f2f2;
            border-radius: 10px;
            border: 1px solid #4a5160;
            padding: 0;
        }

        .country-popover,
        popover,
        popover box,
        list,
        list row {
            background: #2b2f36;
            color: #f2f2f2;
        }

        .stat-card {
            background: #252a33;
            border: 1px solid #404756;
            border-radius: 10px;
            padding: 14px;
        }

        .stat-title {
            color: #9aa3b2;
            font-size: 12px;
            font-weight: 700;
        }

        .stat-value {
            color: #f2f2f2;
            font-size: 18px;
            font-weight: 700;
        }

        .state-on {
            color: #7ee787;
        }

        .state-off {
            color: #ff7b72;
        }

        .state-warn {
            color: #e3b341;
        }

        textview,
        textview text {
            background: #2b2f36;
            color: #f2f2f2;
        }

        scrolledwindow {
            border: 1px solid #4a5160;
            border-radius: 10px;
            background: #2b2f36;
        }
        """
        provider = Gtk.CssProvider()
        provider.load_from_data(css)
        screen = Gdk.Screen.get_default()
        Gtk.StyleContext.add_provider_for_screen(
            screen,
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
        )

    def build_header(self):
        title = Gtk.Label(label=TITLE)
        title.set_xalign(0)
        title.get_style_context().add_class("title-label")

        subtitle = Gtk.Label(label="Persistent GTK UI for wgnord, with built-in debug output.")
        subtitle.set_xalign(0)
        subtitle.get_style_context().add_class("subtitle-label")

        self.root_box.pack_start(title, False, False, 0)
        self.root_box.pack_start(subtitle, False, False, 0)

    def make_stat_card(self, title, key):
        card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        card.get_style_context().add_class("stat-card")
        card.set_hexpand(True)

        title_label = Gtk.Label(label=title)
        title_label.set_xalign(0)
        title_label.get_style_context().add_class("stat-title")

        value_label = Gtk.Label(label="...")
        value_label.set_xalign(0)
        value_label.set_selectable(True)
        value_label.set_line_wrap(True)
        value_label.set_line_wrap_mode(2)
        value_label.get_style_context().add_class("stat-value")

        card.pack_start(title_label, False, False, 0)
        card.pack_start(value_label, False, False, 0)

        self.info_fields[key] = value_label
        return card

    def build_controls(self):
        stats_grid = Gtk.Grid(column_spacing=12, row_spacing=12, column_homogeneous=True)
        self.root_box.pack_start(stats_grid, False, False, 0)

        cards = [
            ("State", "state"),
            ("Selected", "selected"),
            ("Tunnel IP", "ip"),
            ("Endpoint", "endpoint"),
            ("Handshake", "handshake"),
            ("RX / TX", "transfer"),
        ]

        for i, (title, key) in enumerate(cards):
            stats_grid.attach(self.make_stat_card(title, key), i % 3, i // 3, 1, 1)

        country_row = Gtk.Grid(column_spacing=12, row_spacing=12)
        self.root_box.pack_start(country_row, False, False, 0)

        country_label = Gtk.Label(label="Country")
        country_label.set_xalign(0)
        country_label.get_style_context().add_class("section-label")
        country_row.attach(country_label, 0, 0, 1, 1)

        self.country_btn = Gtk.Button()
        self.country_btn.set_hexpand(True)
        self.country_btn.get_style_context().add_class("country-button")
        self.country_btn.connect("clicked", self.on_country_button_clicked)

        country_inner = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        country_inner.set_margin_top(10)
        country_inner.set_margin_bottom(10)
        country_inner.set_margin_start(14)
        country_inner.set_margin_end(14)

        self.country_btn_label = Gtk.Label(label=DEFAULT_COUNTRY)
        self.country_btn_label.set_xalign(0)
        self.country_btn_label.set_hexpand(True)

        arrow = Gtk.Image.new_from_icon_name("pan-down-symbolic", Gtk.IconSize.BUTTON)

        country_inner.pack_start(self.country_btn_label, True, True, 0)
        country_inner.pack_end(arrow, False, False, 0)
        self.country_btn.add(country_inner)

        country_row.attach(self.country_btn, 1, 0, 1, 1)

        self.build_country_popover()

        button_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        self.root_box.pack_start(button_box, False, False, 0)

        self.connect_btn = Gtk.Button(label="Connect Selected")
        self.connect_btn.get_style_context().add_class("suggested-action")
        self.connect_btn.connect("clicked", self.on_connect_selected)
        button_box.pack_start(self.connect_btn, True, True, 0)

        self.au_btn = Gtk.Button(label="Australia")
        self.au_btn.connect("clicked", self.on_quick_connect, "Australia")
        button_box.pack_start(self.au_btn, True, True, 0)

        self.ph_btn = Gtk.Button(label="Philippines")
        self.ph_btn.connect("clicked", self.on_quick_connect, "Philippines")
        button_box.pack_start(self.ph_btn, True, True, 0)

        self.disconnect_btn = Gtk.Button(label="Disconnect")
        self.disconnect_btn.connect("clicked", self.on_disconnect)
        button_box.pack_start(self.disconnect_btn, True, True, 0)

    def build_country_popover(self):
        self.country_popover = Gtk.Popover.new(self.country_btn)
        self.country_popover.set_position(Gtk.PositionType.BOTTOM)
        self.country_popover.set_border_width(8)
        self.country_popover.set_size_request(420, 320)
        self.country_popover.get_style_context().add_class("country-popover")

        pop_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)

        self.country_search = Gtk.SearchEntry()
        self.country_search.set_placeholder_text("Search country")
        self.country_search.connect("search-changed", self.on_country_search_changed)
        pop_box.pack_start(self.country_search, False, False, 0)

        self.country_scroller = Gtk.ScrolledWindow()
        self.country_scroller.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        self.country_scroller.set_min_content_height(260)
        self.country_scroller.set_max_content_height(260)
        pop_box.pack_start(self.country_scroller, True, True, 0)

        self.country_listbox = Gtk.ListBox()
        self.country_listbox.set_activate_on_single_click(True)
        self.country_listbox.connect("row-activated", self.on_country_row_activated)
        self.country_listbox.set_filter_func(self.country_filter_func)
        self.country_scroller.add(self.country_listbox)

        self.country_popover.add(pop_box)

    def build_debug_panel(self):
        debug_label = Gtk.Label(label="Debug Output")
        debug_label.set_xalign(0)
        debug_label.get_style_context().add_class("section-label")
        self.root_box.pack_start(debug_label, False, False, 0)

        self.scroller = Gtk.ScrolledWindow()
        self.scroller.set_hexpand(True)
        self.scroller.set_vexpand(True)
        self.scroller.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        self.root_box.pack_start(self.scroller, True, True, 0)

        self.debug_view = Gtk.TextView()
        self.debug_view.set_editable(False)
        self.debug_view.set_cursor_visible(False)
        self.debug_view.set_monospace(True)
        self.debug_view.set_wrap_mode(Gtk.WrapMode.WORD_CHAR)
        self.debug_view.set_left_margin(8)
        self.debug_view.set_right_margin(8)
        self.debug_buffer = self.debug_view.get_buffer()
        self.scroller.add(self.debug_view)

        footer = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        footer.set_halign(Gtk.Align.END)
        self.root_box.pack_start(footer, False, False, 0)

        self.clear_btn = Gtk.Button(label="Clear Debug")
        self.clear_btn.connect("clicked", self.on_clear_debug)
        footer.pack_start(self.clear_btn, False, False, 0)

        self.append_debug("Ready.\n")

    def strip_ansi(self, text):
        text = ANSI_RE.sub("", text)
        text = text.replace("\r\n", "\n").replace("\r", "\n")
        return text

    def append_debug(self, text):
        clean = self.strip_ansi(text)
        end = self.debug_buffer.get_end_iter()
        self.debug_buffer.insert(end, clean)
        GLib.idle_add(self.scroll_debug_to_bottom)

    def scroll_debug_to_bottom(self):
        mark = self.debug_buffer.create_mark(None, self.debug_buffer.get_end_iter(), False)
        self.debug_view.scroll_mark_onscreen(mark)
        adj = self.scroller.get_vadjustment()
        if adj is not None:
            def _scroll():
                adj.set_value(max(0, adj.get_upper() - adj.get_page_size()))
                return False
            GLib.idle_add(_scroll)
        return False

    def clear_debug(self):
        self.debug_buffer.set_text("")

    def set_info(self, key, value):
        if key in self.info_fields:
            self.info_fields[key].set_text(value)
            if key == "state":
                self.update_state_style(value)

    def update_state_style(self, text):
        if "state" not in self.info_fields:
            return
        ctx = self.info_fields["state"].get_style_context()
        ctx.remove_class("state-on")
        ctx.remove_class("state-off")
        ctx.remove_class("state-warn")

        if text.startswith("ON"):
            ctx.add_class("state-on")
        elif text.startswith("OFF"):
            ctx.add_class("state-off")
        else:
            ctx.add_class("state-warn")

    def set_status(self, text):
        self.set_info("state", text)

    def set_busy(self, busy):
        self.connect_btn.set_sensitive(not busy)
        self.au_btn.set_sensitive(not busy)
        self.ph_btn.set_sensitive(not busy)
        self.disconnect_btn.set_sensitive(not busy)
        self.country_btn.set_sensitive(not busy)
        self.clear_btn.set_sensitive(not busy)

    def set_selected_country(self, country):
        self.selected_country = country
        self.country_btn_label.set_text(country)
        self.set_info("selected", country)

    def human_bytes(self, n):
        try:
            n = int(n)
        except Exception:
            return "?"
        for unit in ["B", "KiB", "MiB", "GiB", "TiB"]:
            if n < 1024 or unit == "TiB":
                return f"{n:.1f} {unit}" if unit != "B" else f"{n} B"
            n /= 1024.0

    def find_program(self, name):
        if os.path.isabs(name):
            return name if os.path.exists(name) else None

        found = shutil.which(name)
        if found:
            return found

        fallbacks = {
            "sudo": ["/run/wrappers/bin/sudo"],
            "pkexec": ["/run/current-system/sw/bin/pkexec"],
            "bash": ["/run/current-system/sw/bin/bash"],
            "wg": ["/run/current-system/sw/bin/wg"],
            "wg-quick": ["/run/current-system/sw/bin/wg-quick"],
            "ip": ["/run/current-system/sw/bin/ip"],
            "wgnord": ["/run/current-system/sw/bin/wgnord"],
        }

        for candidate in fallbacks.get(name, []):
            if os.path.exists(candidate):
                return candidate

        return None

    def resolve_command(self, cmd):
        resolved = list(cmd)
        resolved[0] = self.find_program(cmd[0]) or cmd[0]
        return resolved

    def sudo_path(self):
        return self.find_program("sudo")

    def pkexec_path(self):
        return self.find_program("pkexec")

    def sudo_cached(self):
        sudo = self.sudo_path()
        if not sudo or os.geteuid() == 0:
            return os.geteuid() == 0

        try:
            result = subprocess.run(
                [sudo, "-n", "true"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                text=True,
            )
            return result.returncode == 0
        except Exception:
            return False

    def prompt_for_sudo_password(self):
        dialog = Gtk.Dialog(
            title="Authentication Required",
            transient_for=self,
            flags=Gtk.DialogFlags.MODAL,
        )
        dialog.add_button("Cancel", Gtk.ResponseType.CANCEL)
        dialog.add_button("OK", Gtk.ResponseType.OK)
        dialog.set_default_response(Gtk.ResponseType.OK)

        box = dialog.get_content_area()
        box.set_spacing(10)
        box.set_margin_top(12)
        box.set_margin_bottom(12)
        box.set_margin_start(12)
        box.set_margin_end(12)

        label = Gtk.Label(label="Enter your sudo password to run the VPN command.")
        label.set_xalign(0)

        entry = Gtk.Entry()
        entry.set_visibility(False)
        entry.set_invisible_char("•")
        entry.set_activates_default(True)

        box.pack_start(label, False, False, 0)
        box.pack_start(entry, False, False, 0)

        dialog.show_all()
        response = dialog.run()
        password = entry.get_text() if response == Gtk.ResponseType.OK else None
        dialog.destroy()

        if response != Gtk.ResponseType.OK or not password:
            return None
        return password

    def prepare_privileged_command(self, cmd, interactive):
        cmd = self.resolve_command(cmd)

        if os.geteuid() == 0:
            return cmd, None

        sudo = self.sudo_path()
        if sudo:
            if self.sudo_cached():
                return [sudo] + cmd, None

            if interactive:
                password = self.prompt_for_sudo_password()
                if password is None:
                    raise RuntimeError("Authentication cancelled.")
                return [sudo, "-S", "-p", ""] + cmd, password + "\n"

            raise RuntimeError("Authentication required.")

        pkexec = self.pkexec_path()
        if pkexec and interactive:
            return [pkexec] + cmd, None

        raise RuntimeError("No sudo or pkexec found for privileged command.")

    def run_command_async(self, title, cmd, require_root=False):
        try:
            if require_root:
                final_cmd, stdin_text = self.prepare_privileged_command(cmd, interactive=True)
            else:
                final_cmd, stdin_text = self.resolve_command(cmd), None
        except Exception as e:
            self.append_debug(f"\n[{time.strftime('%H:%M:%S')}] {title}\n")
            self.append_debug(f"Command prep failed: {e}\n")
            self.refresh_status()
            return

        def worker():
            GLib.idle_add(self.set_busy, True)
            GLib.idle_add(self.append_debug, f"\n[{time.strftime('%H:%M:%S')}] {title}\n")
            GLib.idle_add(self.append_debug, f"+ {' '.join(shlex.quote(x) for x in final_cmd)}\n\n")

            try:
                proc = subprocess.Popen(
                    final_cmd,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                    stdin=subprocess.PIPE if stdin_text is not None else None,
                    text=True,
                    bufsize=1,
                )

                if stdin_text is not None and proc.stdin:
                    proc.stdin.write(stdin_text)
                    proc.stdin.flush()
                    proc.stdin.close()

                if proc.stdout:
                    for line in proc.stdout:
                        GLib.idle_add(self.append_debug, line)

                rc = proc.wait()
                GLib.idle_add(self.append_debug, f"\nExit code: {rc}\n")
            except Exception as e:
                GLib.idle_add(self.append_debug, f"\nCommand failed: {e}\n")
            finally:
                GLib.idle_add(self.refresh_status)
                GLib.idle_add(self.set_busy, False)

        threading.Thread(target=worker, daemon=True).start()

    def run_capture(self, cmd, require_root=False):
        cmd = self.resolve_command(cmd)

        if require_root:
            cmd, _ = self.prepare_privileged_command(cmd, interactive=False)

        return subprocess.run(cmd, capture_output=True, text=True)

    def get_tunnel_ip(self):
        try:
            result = self.run_capture(["ip", "-o", "-4", "addr", "show", "dev", "wgnord"], require_root=False)
            if result.returncode != 0 or not result.stdout.strip():
                return "N/A"
            parts = result.stdout.split()
            for part in parts:
                if "/" in part and "." in part:
                    return part
            return "N/A"
        except Exception:
            return "N/A"

    def load_countries(self):
        countries = []

        if os.path.exists(COUNTRIES_FILE):
            try:
                with open(COUNTRIES_FILE, "r", encoding="utf-8") as f:
                    tokens = f.read().split()

                current = []
                for token in tokens:
                    if token.isdigit():
                        if current:
                            countries.append(" ".join(current))
                            current = []
                    else:
                        current.append(token)

                if current:
                    countries.append(" ".join(current))
            except Exception as e:
                self.append_debug(f"Failed reading {COUNTRIES_FILE}: {e}\n")

        if not countries:
            countries = [
                "Australia", "Philippines", "Albania", "Algeria", "Andorra", "Argentina",
                "Armenia", "Austria", "Azerbaijan", "Bahamas", "Bangladesh", "Belgium",
                "Belize", "Bermuda", "Bhutan", "Bolivia", "Bosnia and Herzegovina",
                "Brazil", "Brunei Darussalam", "Bulgaria", "Cambodia", "Canada",
                "Cayman Islands", "Chile", "Colombia", "Costa Rica", "Croatia", "Cyprus",
                "Czech Republic", "Denmark", "Dominican Republic", "Ecuador", "Egypt",
                "El Salvador", "Estonia", "Finland", "France", "Georgia", "Germany",
                "Ghana", "Greece", "Greenland", "Guam", "Guatemala", "Honduras",
                "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Ireland",
                "Isle of Man", "Israel", "Italy", "Jamaica", "Japan", "Jersey",
                "Kazakhstan", "Kenya", "Latvia", "Lebanon", "Liechtenstein", "Lithuania",
                "Luxembourg", "Malaysia", "Malta", "Mexico", "Moldova", "Monaco",
                "Mongolia", "Montenegro", "Morocco", "Myanmar", "Nepal", "Netherlands",
                "New Zealand", "Nigeria", "North Macedonia", "Norway", "Pakistan",
                "Panama", "Papua New Guinea", "Paraguay", "Peru", "Poland", "Portugal",
                "Puerto Rico", "Romania", "Serbia", "Singapore", "Slovakia", "Slovenia",
                "South Africa", "South Korea", "Spain", "Sri Lanka", "Sweden",
                "Switzerland", "Taiwan", "Thailand", "Trinidad and Tobago", "Türkiye",
                "Ukraine", "United Arab Emirates", "United Kingdom", "United States",
                "Uruguay", "Uzbekistan", "Venezuela", "Vietnam"
            ]

        seen = set()
        ordered = []
        for c in countries:
            if c not in seen:
                seen.add(c)
                ordered.append(c)

        for fav in ["Philippines", "Australia"]:
            if fav in ordered:
                ordered.remove(fav)

        return ["Australia", "Philippines"] + ordered

    def populate_country_dropdown(self, countries, selected):
        for row in self.country_rows:
            self.country_listbox.remove(row)
        self.country_rows.clear()

        for country in countries:
            row = Gtk.ListBoxRow()
            row.country = country

            label = Gtk.Label(label=country)
            label.set_xalign(0)
            label.set_margin_top(8)
            label.set_margin_bottom(8)
            label.set_margin_start(10)
            label.set_margin_end(10)

            row.add(label)
            self.country_listbox.add(row)
            self.country_rows.append(row)

        self.country_listbox.show_all()
        self.set_selected_country(selected)
        self.country_search.set_text("")
        self.country_listbox.invalidate_filter()

    def country_filter_func(self, row):
        query = self.country_search.get_text().strip().lower()
        if not query:
            return True
        return query in row.country.lower()

    def on_country_search_changed(self, _entry):
        self.country_listbox.invalidate_filter()

    def on_country_button_clicked(self, _button):
        self.country_search.set_text("")
        self.country_listbox.invalidate_filter()
        self.country_popover.show_all()
        self.country_popover.popup()
        GLib.idle_add(self.country_search.grab_focus)

    def on_country_row_activated(self, _listbox, row):
        self.set_selected_country(row.country)
        self.country_popover.popdown()

    def get_selected_country(self):
        return self.selected_country.strip() if self.selected_country else ""

    def refresh_status(self):
        try:
            self.set_info("selected", self.get_selected_country() or DEFAULT_COUNTRY)
            self.set_info("ip", "N/A")
            self.set_info("endpoint", "N/A")
            self.set_info("handshake", "N/A")
            self.set_info("transfer", "N/A")

            direct = self.run_capture(["wg", "show", "wgnord"], require_root=False)
            use_root = direct.returncode != 0

            if use_root:
                if os.geteuid() != 0 and not self.sudo_cached():
                    self.set_status("Auth required")
                    return
                show_result = self.run_capture(["wg", "show", "wgnord"], require_root=True)
            else:
                show_result = direct

            if show_result.returncode != 0:
                self.set_status("OFF")
                return

            endpoint_res = self.run_capture(["wg", "show", "wgnord", "endpoints"], require_root=use_root)
            hs_res = self.run_capture(["wg", "show", "wgnord", "latest-handshakes"], require_root=use_root)
            tx_res = self.run_capture(["wg", "show", "wgnord", "transfer"], require_root=use_root)

            self.set_info("ip", self.get_tunnel_ip())

            if endpoint_res.returncode == 0:
                ep_parts = endpoint_res.stdout.strip().split()
                if len(ep_parts) >= 2:
                    self.set_info("endpoint", ep_parts[1])

            if hs_res.returncode == 0:
                hs_parts = hs_res.stdout.strip().split()
                if len(hs_parts) >= 2 and hs_parts[1].isdigit() and hs_parts[1] != "0":
                    age = int(time.time()) - int(hs_parts[1])
                    self.set_info("handshake", f"{age}s ago")
                    self.set_status("ON")
                else:
                    self.set_info("handshake", "waiting")
                    self.set_status("ON, waiting for handshake")
            else:
                self.set_status("ON")

            if tx_res.returncode == 0:
                tr_parts = tx_res.stdout.strip().split()
                if len(tr_parts) >= 3:
                    rx = self.human_bytes(tr_parts[1])
                    tx = self.human_bytes(tr_parts[2])
                    self.set_info("transfer", f"{rx} / {tx}")

        except Exception:
            self.set_status("Status unavailable")

    def periodic_refresh(self):
        self.refresh_status()
        return True

    def on_connect_selected(self, _button):
        country = self.get_selected_country()
        if not country:
            self.append_debug("\nNo country selected.\n")
            return
        self.run_command_async(f"Connect {country}", ["wgnord", "c", country], require_root=True)

    def on_quick_connect(self, _button, country):
        self.set_selected_country(country)
        self.run_command_async(f"Connect {country}", ["wgnord", "c", country], require_root=True)

    def on_disconnect(self, _button):
        cmd = (
            "wg-quick --quiet down /etc/wireguard/wgnord.conf 2>/dev/null || "
            "wg-quick --quiet down wgnord 2>/dev/null || "
            "ip link del wgnord 2>/dev/null || true"
        )
        self.run_command_async("Disconnect", ["bash", "-lc", cmd], require_root=True)

    def on_clear_debug(self, _button):
        self.clear_debug()
        self.append_debug("Ready.\n")


def main():
    win = NordVPNWindow()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()


if __name__ == "__main__":
    main()