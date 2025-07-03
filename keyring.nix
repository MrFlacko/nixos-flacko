{ config, pkgs, cmod, lib, ... }:
{
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring  = true;
  security.pam.services.login.enableGnomeKeyring = true;
}