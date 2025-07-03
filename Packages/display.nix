# /etc/nixos/display.nix  – edited to stop the NVIDIA 555 Wayland freeze
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  ##############################################
  # NVIDIA 555 closed driver (Wayland-ready)
  ##############################################
  hardware.graphics.enable  = true;
  services.xserver.videoDrivers = [ "nvidia" ];

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

  # Work-around: tell KWin to skip explicit-sync
  # (stops the page-flip time-outs that freeze)
  environment.sessionVariables.KWIN_DRM_NO_IMPLICIT_SYNC = "1";

  # KDE Plasma on Wayland (default)
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    wayland.compositor = "kwin";
  };

  # ##########################################################
  # # Wide monitor not wide setup. This shit just doesn't work
  # ##########################################################
  # # 1) Bake the custom EDID into the Nix store’s firmware tree
  # hardware.firmware = [
  #   (pkgs.runCommandNoCC "custom-edid" { compressFirmware = false; } ''
  #     mkdir -p $out/lib/firmware/edid
  #     # <-- this line pulls the .bin into the build,
  #     #     then copies it as edid.bin in the firmware tree
  #     cp ${./edid/edid-2560x1440.bin} \
  #        $out/lib/firmware/edid/edid.bin
  #   '')
  # ];

  # boot.kernelParams = lib.mkForce [
  #   "drm.edid_firmware=card1-DP-2:edid/edid.bin"
  # ];
}