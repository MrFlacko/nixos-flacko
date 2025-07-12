{ config, pkgs, cmod, ... }:

{
  environment.systemPackages = with pkgs; [
    jellyfin-media-player
  ];
}