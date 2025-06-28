{ config, lib, pkgs, modulesPath, ... }:

{
  boot.kernelParams = [ 
    "nvidia-drm.modeset=1" 
    "nvidia-modeset.conceal_vrr_caps=1"
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
