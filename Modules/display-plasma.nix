# ./Modules/display-wayland.nix
{ config, lib, pkgs, modulesPath, cmod, ... }:

{
  # KDE Plasma on Wayland (default)
  services.desktopManager.plasma6.enable = true;

  services.displayManager.sddm.wayland.enable = true;

  # Work-around: tell KWin to skip explicit-sync
  # (stops the page-flip time-outs that freeze)
  environment.sessionVariables = {
    KWIN_DRM_NO_IMPLICIT_SYNC = "1";
  };
}