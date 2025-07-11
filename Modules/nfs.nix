# ./Modules/display-xorg.nix
# https://wiki.nixos.org/wiki/Xorg
{ config, lib, pkgs, modulesPath, cmod, ... }:


{
  fileSystems."/mnt/alfred" = {
    device  = "172.16.0.10:/mnt/big";
    fsType  = "nfs4";
    options = [
      "rw" "hard" "intr"
      "vers=4.2"
      "rsize=1048576" "wsize=1048576"
      "nconnect=4"
    ];
  };
  
  # Smoothing out RAM usage
  boot.kernel.sysctl = {
    "vm.dirty_writeback_centisecs" = "100";
    "vm.dirty_ratio"               = "15";
    "vm.dirty_background_ratio"    = "10";
  };
}