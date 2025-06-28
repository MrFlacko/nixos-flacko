{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  environment.shellAliases = {
    build-nix = "bash /etc/nixos/scripts/build-nix.sh";
    pkgsearch = "bash /etc/nixos/scripts/pkgsearch.sh";
    pkginstall = "bash /etc/nixos/scripts/pkginstall.sh";
    blackscreen = "bash /etc/nixos/scripts/blackscreen.sh";
    nixopen = "code /home/flacko/.config/nix-config";
    pkgedit = "code /home/flacko/.config/nix-config/packages.nix";
  };
}
