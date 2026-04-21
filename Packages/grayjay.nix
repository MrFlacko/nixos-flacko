{ pkgs, ... }:

let
  grayjaySrc = pkgs.fetchzip {
    url = "https://updater.grayjay.app/Apps/Grayjay.Desktop/Grayjay.Desktop-linux-x64.zip";
    hash = "sha256-6bnAibjbWBZtBXRSGdmSoGNffaEsYlXDr4vvjqgUSl8=";
  };

  grayjayWrapper = pkgs.writeShellScript "grayjay-wrapper" ''
    set -euo pipefail

    APPDIR="$HOME/.local/share/grayjay"
    SRC="${grayjaySrc}"

    mkdir -p "$APPDIR"
    [[ ! -e "$APPDIR/Grayjay" ]] && cp -r "$SRC"/. "$APPDIR"/ && chmod -R u+w "$APPDIR"

    cd "$APPDIR"
    "$APPDIR/Grayjay" "$@"
  '';

  grayjay = pkgs.buildFHSEnv {
    name = "grayjay";
    targetPkgs = pkgs: with pkgs; [
      icu openssl libsecret dbus udev zlib libgbm
      # libX11 libXcomposite libXdamage libXext libXfixes libXrandr libxcb
      xorg.libX11 xorg.libXcomposite xorg.libXdamage xorg.libXext xorg.libXfixes xorg.libXrandr xorg.libxcb
      gtk3 glib nss nspr atk cups libdrm expat mesa
      libxkbcommon pango cairo alsa-lib libGL
      stdenv.cc.cc.lib
    ];
    runScript = "${grayjayWrapper}";
  };
in
{
  environment.systemPackages = [ grayjay ];
}