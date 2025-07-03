{ config, pkgs, ... }:

let
  cmod = {
    locale = "en_AU.UTF-8";
    timezone = "Australia/Sydney";
    kblayout = "au";
    docker = false;
    shortcuts = true;
  };
in  
{
  _module.args.cmod = cmod;

  imports = [
    ./hardware-configuration.nix
    ./display.nix
    ./networking.nix
    ./audio.nix
    ./steam.nix
    ./packages.nix
    ./razer.nix
    ./home-manager.nix
    ./users.nix
    ./langtime.nix
  ]
  ++ (if cmod.docker then [ ./docker.nix ] else [])
  ++ (if cmod.docker then [ ./shortcuts.nix ] else [])
  ;
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Experimental Features Nix
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    max-jobs = "auto";
    cores = 0;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  system.stateVersion = "25.05"; # Did you read the comment? NUP haha
}
