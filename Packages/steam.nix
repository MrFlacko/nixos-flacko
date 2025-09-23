{ config, lib, pkgs, ... }:

{
  # Steam + official Proton
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    extraCompatPackages = with pkgs; [ proton-ge-bin ]; # Adding proton-ge-bin5
  };

  # 32-bit drivers (needed for Proton)
  hardware.graphics.enable32Bit = true;
#NVidia  hardware.nvidia.modesetting.enable = true;

  # optional: Proton-GE updater
  environment.systemPackages = with pkgs; [
    protonup-qt gamescope
  ];

  services.xserver = {
    enable = true; # pulls in Xwayland – needed even on Wayland
    videoDrivers = [ "amdgpu" ]; # use the proprietary driver
  #Nvidia  videoDrivers = [ "nvidia" ];
  };

  programs.gamemode.enable = true;
  environment.variables = {
    __GL_MaxFramesAllowed = "1";   # Nvidia, 1 frame queue
  };

  services.power-profiles-daemon.enable = true;
}
