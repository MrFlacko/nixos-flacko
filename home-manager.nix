{ config, lib, pkgs, ... }:

## Home manager allows you to manager your system dot.files.
# https://nix-community.github.io/home-manager/index.xhtml#ch-installation

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;
in
{
  imports = [ (import "${home-manager}/nixos") ];
  users.users.flacko.isNormalUser = true;
  home-manager.users.flacko = { pkgs, ... }: {
    home.packages = with pkgs; [
      pkgs.nerd-fonts.fira-code
    ];
    programs.bash.enable = true;

    # Disable warning for version mismatch
    home.enableNixpkgsReleaseCheck = false;
    home.stateVersion = "25.05";

    ## Caprine CSS Fix not showing dialog boxes
    # It shows preferences window at startup but I couldn't get around it.
    home.file.".config/Caprine/custom.css".text = ''
      html.hide-preferences-window div[class="x9f619 x1n2onr6 x1ja2u2z"] > div:nth-of-type(3) > div > div {
        display: block !important;
      }
    '';
  };
}