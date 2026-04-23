{ config, lib, pkgs, ... }:

{
  # Steam + official Proton
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = with pkgs; [
      gst_all_1.gst-plugins-base
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-libav
      proton-ge-bin 
    ];
  };

  # 32-bit drivers (needed for Proton)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  # NVidia  hardware.nvidia.modesetting.enable = true;

  # optional: Proton-GE updater
  environment.systemPackages = with pkgs; [
    protonup-qt gamescope
  ];

  services.xserver = {
    enable = true; # pulls in Xwayland – needed even on Wayland
    videoDrivers = [ "amdgpu" ]; # use the proprietary driver
    # Nvidia  videoDrivers = [ "nvidia" ];
  };

  programs.gamemode.enable = true;
  environment.variables = {
    __GL_MaxFramesAllowed = "1";   # Nvidia, 1 frame queue
  };

  services.power-profiles-daemon.enable = true;
}
