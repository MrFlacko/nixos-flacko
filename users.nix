
{ config, lib, pkgs, ... }:

{
  users.users.flacko = {
    isNormalUser = true;
    description = "Joshua";
    extraGroups = [ "wheel" "video" "networkmanager" "wireshark" "audio" "openrazer" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };
}