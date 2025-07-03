{ config, pkgs, cmod, ... }:

{
  ## Made with https://nixos.wiki/wiki/Docker

  # Enable Docker
  virtualisation.docker.enable = true;

  # Add the user to the group docker (Groups don't apply unless you restart)
  users.users.flacko.extraGroups = [ "docker" ];

  # # This can also be done with docker for the socket
  # users.extraGroups.docker.members = [ "username-with-access-to-socket" ];

  # Using Docker in Rootless mode
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Installing Docker NixOS
  environment.systemPackages = with pkgs; [
    docker_28 docker-compose
  ];

  virtualisation.docker.daemon.settings = {
    data-root = "/mnt/8TBDrive/VMs/Docker";
  };
}