{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnome-calendar
  ];

  programs.dconf.enable = true;
  services.gnome.evolution-data-server.enable = true;

  # only if you want Google / Nextcloud / online accounts
  services.gnome.gnome-online-accounts.enable = true;
  services.gnome.gnome-keyring.enable = true;
}