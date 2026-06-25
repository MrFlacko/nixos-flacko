{ config, lib, pkgs, ... }:

let
  pkgsUnstable = import <nixos-unstable> {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
in
{
  nixpkgs.config.allowUnfree = true;

  programs.steam = {
    enable = true;

    # Latest Steam from nixos-unstable.
    package = pkgsUnstable.steam;

    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;

    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];

    extraPackages = with pkgs; [
      gamemode
      gamescope
    ];

    protontricks.enable = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.steam-hardware.enable = true;

  services.xserver = {
    enable = true;
    videoDrivers = [ "amdgpu" ];
  };

  programs.gamemode.enable = true;

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  environment.systemPackages = with pkgs; [
    protonup-qt
    gamescope
    gamemode
    mangohud
  ];

  services.power-profiles-daemon.enable = true;
}