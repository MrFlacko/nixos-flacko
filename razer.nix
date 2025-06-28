{ config, lib, pkgs, modulesPath, ... }:

{
  # Maybe one day I should add the command, I forgot :)
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # https://nixos.wiki/wiki/Hardware/Razer
  hardware.openrazer.enable = true;
  environment.systemPackages = with pkgs; [ openrazer-daemon polychromatic ];
}