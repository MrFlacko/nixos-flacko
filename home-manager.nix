{ config, lib, pkgs, ... }:

## Home manager allows you to manager your system dot.files.
# https://nix-community.github.io/home-manager/index.xhtml#ch-installation
# sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz home-manager
# sudo nix-channel --update

{
  imports = [ <home-manager/nixos> ];

  users.users.flacko.isNormalUser = true;

  home-manager.users.flacko = { pkgs, ... }: {
    home.stateVersion = "25.05";
    home.enableNixpkgsReleaseCheck = false;

    programs.bash.enable = true;

    home.packages = with pkgs; [
      nerd-fonts.fira-code
    ];

    home.file.".config/Caprine/custom.css".text = ''
      html.hide-preferences-window div[class="x9f619 x1n2onr6 x1ja2u2z"] > div:nth-of-type(3) > div > div {
        display: block !important;
      }
    '';
  };
}
