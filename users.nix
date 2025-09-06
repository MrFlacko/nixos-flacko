
{ config, lib, pkgs, ... }:

{
  users.users.flacko = {
    isNormalUser = true;
    description = "Joshua";
    extraGroups = [ "wheel" "video" "networkmanager" "wireshark" "audio" "openrazer" "lpadmin" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };
}