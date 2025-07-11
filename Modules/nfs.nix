# ./Modules/display-xorg.nix
# https://wiki.nixos.org/wiki/Xorg
{ config, lib, pkgs, modulesPath, cmod, ... }:


{
  fileSystems."/mnt/alfred" = {
    device = "172.16.0.10:/mnt/big";
    fsType  = "nfs4";
    options = [ "rw" "hard" "intr" ];
  };
}