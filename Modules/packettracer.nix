{ config, lib, pkgs, cmod, ... }:

{
  # Making sure packet tracer can build from a specific version
  nixpkgs.overlays = [(
    final: prev:
    let legacyPkgs = import ( 
      builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-24.11.tar.gz" 
      ) { inherit (prev) system config; };
     in { ciscoPacketTracer8 = legacyPkgs.ciscoPacketTracer8; }
  )];

  environment.systemPackages = with pkgs; [
    ciscoPacketTracer8
  ];

  # Garbage ass shit code fuck you chatgpt
  # (writeShellScriptBin "packettracer-clean" ''
  #   exec ${runuser}/bin/runuser -u packettracer -- \
  #     env QT_STYLE_OVERRIDE=fusion \
  #         QT_QPA_PLATFORMTHEME="" \
  #         XDG_CURRENT_DESKTOP=GNOME \
  #     ${ciscoPacketTracer8}/bin/packettracer "$@"
  # '')
}