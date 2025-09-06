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
    enable = true;
    wayland.enable = false;
#    wayland.compositor = "kwin";
    theme = "elarun"; # ls /run/current-system/sw/share/sddm/themes/
  };

  environment.systemPackages = with pkgs; [
    kdePackages.sddm-kcm
  ];
}
