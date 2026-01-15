# ./Packages/graphics.nix
{ config, lib, pkgs, modulesPath, cmod, ... }:

{
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.xserver.enable = true; # Use for both wayland and xorg
  services.fwupd.enable = true;
  hardware.enableRedistributableFirmware = true;

  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  environment.systemPackages = with pkgs; [
    kdePackages.sddm-kcm amdgpu_top vulkan-tools pciutils corectrl rocmPackages.rocm-smi
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      libva-vdpau-driver libva mesa-demos vulkan-tools
    ];
  };

  services.displayManager.sddm = {
    enable = true;
    theme = "elarun"; # ls /run/current-system/sw/share/sddm/themes/
  };
  
  #Nvidia  services.xserver.videoDrivers = [ "nvidia" ];
  #Nvidia#  boot.kernelParams = [ 
  #Nvidia#    "nvidia-drm.modeset=1" 
  #Nvidia#    "nvidia-modeset.conceal_vrr_caps=1"
  #Nvidia#  ];
  #Nvidia#  hardware.nvidia = {
  #Nvidia#    modesetting.enable = true;
  #Nvidia#    nvidiaSettings = true;
  #Nvidia#    open = false;
  #Nvidia#    package = config.boot.kernelPackages.nvidiaPackages.stable;
  #Nvidia#  };
}
