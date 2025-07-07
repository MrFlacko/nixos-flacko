# ./Modules/display-xorg.nix
# https://wiki.nixos.org/wiki/Xorg
{ config, lib, pkgs, modulesPath, cmod, ... }:


{
  services.xserver = { desktopManager.cinnamon.enable = true; };
  services.displayManager.defaultSession = "cinnamon";

}