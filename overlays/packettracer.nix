# overlays/packettracer.nix
(
  final: prev:
  let legacyPkgs = import (
    builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-24.11.tar.gz"
    ) { inherit (prev) system config; };
  in { ciscoPacketTracer8 = legacyPkgs.ciscoPacketTracer8; }
)