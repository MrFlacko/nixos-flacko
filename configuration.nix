{ config, pkgs, ... }:

let cmod = {
    locale = "en_AU.UTF-8";
    timezone = "Australia/Sydney";
    kblayout = "au";
    docker = true;
    shortcuts = true;
    keyring = true;
    packettracer = false;
    virtmanager = false;
    display-plasma = false;
    display-cinnamon = true;
    jellyfin = true;
    audacity = true;
    nfs = false;
  };
  defaultSession =
    if cmod.display-plasma then "plasma"
    else if cmod.display-cinnamon then "cinnamon"
    else null;
in {
  _module.args.cmod = cmod;
  imports = [
    # Normal
    ./hardware-configuration.nix
    ./home-manager.nix
    ./users.nix
    ./langtime.nix

    # Packages
    ./Packages/networking.nix
    ./Packages/audio.nix
    ./Packages/steam.nix
    ./Packages/packages.nix
    ./Packages/razer.nix
    ./Packages/graphics.nix
  ]
  # Modules
  ++ (if cmod.docker then [ ./Modules/docker.nix ] else [])
  ++ (if cmod.shortcuts then [ ./Modules/shortcuts.nix ] else [])
  ++ (if cmod.keyring then [ ./Modules/keyring.nix ] else [])
  ++ (if cmod.packettracer then [ ./Modules/packettracer.nix ] else [])
  ++ (if cmod.virtmanager then [ ./Modules/virtmanager.nix ] else [])
  ++ (if cmod.display-plasma then [ ./Modules/display-plasma.nix ] else [])
  ++ (if cmod.display-cinnamon then [ ./Modules/display-cinnamon.nix ] else [])
  ++ (if cmod.jellyfin then [ ./Modules/jellyfin.nix ] else [])
  ++ (if cmod.audacity then [ ./Modules/audacity.nix ] else [])
  ++ (if cmod.nfs then [ ./Modules/nfs.nix ] else [])
  ;
  
  services.displayManager.defaultSession = defaultSession;
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Experimental Features Nix
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    max-jobs = "auto";
    cores = 0;
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.brlaser ];
    openFirewall = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  nixpkgs.config = {
    allowUnfree = true;  # you likely already need this for Packet Tracer
    permittedInsecurePackages = [ "qtwebengine-5.15.19" ];
  };


  system.stateVersion = "25.05"; 
}
