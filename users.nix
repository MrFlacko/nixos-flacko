
{ config, lib, pkgs, modulesPath, ... }:

{
  users.users.flacko = {
    isNormalUser = true;
    description = "Joshua";
    extraGroups = [ "wheel" "video" "networkmanager" "wireshark" "audio" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };
}