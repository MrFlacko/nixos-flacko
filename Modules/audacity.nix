{ config, pkgs, cmod, lib, ... }:

let
  gsnap = pkgs.stdenv.mkDerivation {
    pname = "gsnap-vst";
    version = "local";
    src = ./Assets/GSnap.so;
    dontUnpack = true;

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];

    buildInputs = [
      pkgs.jack2
      pkgs.stdenv.cc.cc 
      pkgs.xorg.libX11 
      pkgs.libGL 
    ];

    installPhase = ''
      mkdir -p $out
      cp $src $out/GSnap.so
    '';
  };
in {
  home-manager.users.flacko = {
    home.packages = [ pkgs.audacity ];
    home.file.".vst/GSnap.so".source = "${gsnap}/GSnap.so";
  };
}


# sudo mkdir /etc/nixos/Assets
# sudo mv ~/Downloads/GSnapLinux64.zip /etc/nixos/Assets/
# https://gvst.uk/Downloads/Get/GSnapLinux64.zip