{ config, lib, pkgs, cmod, ... }:

{
  # Need to add an alias to show aliases, I keep forgetting them
  environment.shellAliases = {
    build-nix = "bash /etc/nixos/Scripts/build-nix.sh";
    pkgsearch = "bash /etc/nixos/Scripts/pkgsearch.sh";
    pkginstall = "bash /etc/nixos/Scripts/pkginstall.sh";
    bs = "bash /etc/nixos/Scripts/blackscreen.sh";
    nixopen = "code /home/flacko/.config/nix-config";
    pkgedit = "code /home/flacko/.config/nix-config/packages.nix";
    traceroute = "mtr";
    smm = "~/.local/bin/smm";
  };

  programs.bash.interactiveShellInit = ''
    vpn() {
      case "$1" in
        c|connect)
          sudo wgnord c "''${2:-Australia}"
          ;;
        d|disconnect)
          sudo wg-quick --quiet down /etc/wireguard/wgnord.conf 2>/dev/null \
            || sudo wg-quick --quiet down wgnord 2>/dev/null \
            || sudo ip link del wgnord 2>/dev/null || true
          ;;
        show|status)
          if ! sudo wg show wgnord >/dev/null 2>&1; then
            echo "Nord: OFF"; return 1
          fi
          hs=$(sudo wg show wgnord latest-handshakes | awk 'NR==1{print $2}')
          now=$(date +%s)
          [ -n "$hs" ] && [ "$hs" != "0" ] && echo "Nord: ON (handshake $((now-hs))s ago)" || echo "Nord: OFF"
          ;;
        *)
          echo "usage: vpn {c [country]|d|show}"; return 2 ;;
      esac
    }
  '';
}