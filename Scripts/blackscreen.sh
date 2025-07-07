#!/usr/bin/env bash
xorg() { sleep 1; xset dpms force off; }

wayland() {
  sleep 1;
  dbus-send --session --print-reply \
    --dest=org.kde.kglobalaccel \
    /component/org_kde_powerdevil \
    org.kde.kglobalaccel.Component.invokeShortcut \
    string:'Turn Off Screen'
}

[[ $XDG_SESSION_TYPE == wayland || -n $WAYLAND_DISPLAY ]] && wayland || xorg