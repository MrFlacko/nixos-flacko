{ config, pkgs, cmod, ... }:

{
  # https://nixos.wiki/wiki/Virt-manager
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["flacko"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;  
  virtualisation.libvirtd.allowedBridges = [ "br0" ];
  
  # GNS3
  environment.systemPackages = with pkgs; [ gns3-gui ];

  home-manager.users.flacko = { pkgs, ... }: {
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
  };
}