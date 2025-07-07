# ./Packages/graphics.nix
{ config, lib, pkgs, modulesPath, cmod, ... }:

{
  hardware.graphics.enable  = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.enable = true; # Use for both wayland and xorg

  boot.kernelParams = [ 
    "nvidia-drm.modeset=1" 
    "nvidia-modeset.conceal_vrr_caps=1"
  ];

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.displayManager.sddm = {
    wayland.enable = true;
    wayland.compositor = "kwin";
  };

  services.displayManager.sddm.enable = true;
}