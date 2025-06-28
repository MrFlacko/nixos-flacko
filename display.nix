# /etc/nixos/display.nix  – edited to stop the NVIDIA 555 Wayland freeze
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  ##############################################
  # NVIDIA 555 closed driver (Wayland-ready)
  ##############################################
  hardware.graphics.enable  = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;       # required for Wayland
    nvidiaSettings     = true;
    open   = false;                  # closed blobs for your 3070 Ti
    package = config.boot.kernelPackages.nvidiaPackages.stable;   # 555.xx
  };

  ##############################################
  # Work-around: tell KWin to skip explicit-sync
  # (stops the page-flip time-outs that freeze)
  ##############################################
  environment.sessionVariables.KWIN_DRM_NO_IMPLICIT_SYNC = "1";

  ##############################################
  # KDE Plasma on Wayland (default)
  ##############################################
  services.xserver.enable                = true;
  services.displayManager.sddm.enable    = true;
  services.desktopManager.plasma6.enable = true;
  # leave defaultSession unset → SDDM shows “Plasma (Wayland)”


  # ##############################################
  # # Wide monitor not wide setup
  # ##############################################
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