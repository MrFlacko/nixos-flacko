{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # https://nixos.wiki/wiki/Hardware/Razer
  hardware.openrazer.enable = true;
  users.users.flacko = { extraGroups = [ "openrazer" ]; };
  environment.systemPackages = with pkgs; [ openrazer-daemon polychromatic ];
}