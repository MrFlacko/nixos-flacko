{ config, pkgs, lib, cmod, ... }:
{
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "run-nordvpn-gui" ''
      export GI_TYPELIB_PATH="${lib.makeSearchPath "lib/girepository-1.0" [
        gtk3
        pango
        glib
        gdk-pixbuf
        cairo
      ]}:$GI_TYPELIB_PATH"

      export LD_LIBRARY_PATH="${lib.makeLibraryPath [
        gtk3
        pango
        glib
        gdk-pixbuf
        cairo
        harfbuzz
      ]}:$LD_LIBRARY_PATH"

      exec ${pkgs.python3.withPackages (ps: with ps; [ pygobject3 ])}/bin/python3 \
        /home/flacko/.config/nix-config/Scripts/nordvpn.py
    '')
  ];
}