# ./Packages/graphics.nix
{ config, lib, pkgs, modulesPath, cmod, ... }:

{
  #Nvidia  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.xserver.enable = true; # Use for both wayland and xorg

  boot.initrd.kernelModules = [ "amdgpu" ];

#Nvidia  boot.kernelParams = [ 
#Nvidia    "nvidia-drm.modeset=1" 
#Nvidia    "nvidia-modeset.conceal_vrr_caps=1"
#Nvidia  ];

#Nvidia  hardware.nvidia = {
#Nvidia    modesetting.enable = true;
#Nvidia    nvidiaSettings = true;
#Nvidia    open = false;
#Nvidia    package = config.boot.kernelPackages.nvidiaPackages.stable;
#Nvidia  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      libva
      mesa-demos
      amdgpu_top
      nvtopPackages.amd
      radeontop
      lm_sensors
      vulkan-tools
      pciutils
      corectrl
      rocmPackages.rocm-smi
    ];
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false;
#    wayland.compositor = "kwin";
    theme = "elarun"; # ls /run/current-system/sw/share/sddm/themes/
  };

  environment.systemPackages = with pkgs; [
    kdePackages.sddm-kcm
  ];
}
