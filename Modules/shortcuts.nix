{ config, lib, pkgs, cmod, ... }:

{
  # Need to add an alias to show aliases, I keep forgetting them
  environment.shellAliases = {
    build-nix = "bash /etc/nixos/Scripts/build-nix.sh";
    pkgsearch = "bash /etc/nixos/Scripts/pkgsearch.sh";
    pkginstall = "bash /etc/nixos/Scripts/pkginstall.sh";
    blackscreen = "bash /etc/nixos/Scripts/blackscreen.sh";
    nixopen = "code /home/flacko/.config/nix-config";
    pkgedit = "code /home/flacko/.config/nix-config/packages.nix";
  };
}