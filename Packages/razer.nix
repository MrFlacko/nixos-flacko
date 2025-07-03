{ config, lib, pkgs, ... }:

{
  # https://nixos.wiki/wiki/Hardware/Razer
  hardware.openrazer.enable = true;
  environment.systemPackages = with pkgs; [ openrazer-daemon polychromatic ];
}