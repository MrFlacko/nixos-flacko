## Packettracer uses some legacy shit because the updated binary looks for new tar.gz
# overlays/packettracer.nix
final: prev:

let
  # libxml2 before the SONAME bump (ships libxml2.so.2)
  legacy = import (builtins.fetchTarball {
    url    = "https://github.com/NixOS/nixpkgs/archive/refs/tags/23.05.tar.gz";
    sha256 = "10wn0l08j9lgqcw8177nh2ljrnxdrpri7bp0g7nvrsn9rkawvlbf";
  }) { inherit (prev) system; };
in
{
  # patch the real build
  ciscoPacketTracer8-unwrapped = prev.ciscoPacketTracer8-unwrapped.overrideAttrs (old: {
    # drop the new libxml2, add the old one, give patchelf its path
    buildInputs       = (old.buildInputs or []) ++ [ legacy.libxml2 ];
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ prev.autoPatchelfHook ];
    autoPatchelfSearchPath = [ "${legacy.libxml2}/lib" ];
  });
}