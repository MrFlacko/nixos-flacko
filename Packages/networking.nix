{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # Use NetworkManager (not systemd-networkd) and make the bridge declarative via NM profiles.
  networking.useNetworkd = false;

  services.resolved.enable = true;
  services.dbus.enable = true;

  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    plugins = [ pkgs.networkmanager-openvpn ];
  };


  # Copied from https://github.com/celesrenata/nix-flakes/blob/main/esnixi/networking.nix
  networking.dhcpcd.wait = "background"; # Stop nix taking ages
  networking.bridges = {
    "br0" = {
      interfaces = [ "eno1" ];  # Your active network interface
    };
  };

  networking.interfaces.br0 = {
    useDHCP = true;  
  };

  # Enable IP forwarding for VM traffic
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
  
  # Allow bridge traffic for VMs
  networking.firewall.trustedInterfaces = [ "br0" ];

  ## End of copied ##


  networking.firewall.allowedTCPPorts = [
    47989  # Sunshine control
    47984  # Sunshine web UI / pairing
    8080   # other
    48010  # Sunshine session/aux TCP
  ];

  networking.firewall.allowedUDPPortRanges = [
    { from = 47998; to = 48010; }  # streaming
    { from = 8000; to = 9000; }    # parsec out
  ];
  
  # Disable reverse-path filtering – without this the tunnel
  # comes up, packets get dropped, the client reconnects forever.
  networking.firewall.checkReversePath = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.rp_filter" = 2;
    "net.ipv4.conf.default.rp_filter" = 2;
  };

  environment.systemPackages = with pkgs; [ 
    wireguard-tools iptables networkmanager-openvpn mtr whois nmap 
    bind.dnsutils tcpdump iperf3 ethtool bmon wireshark
  ];

  boot.kernelModules = [ "wireguard" ];

  programs.wireshark.enable = true;
  programs.wireshark.dumpcap.enable = true;
  programs.wireshark.usbmon.enable = false;

  # STINKY!!
  #   # br0 gets DHCP, eno1 is a pure bridge port (no IP, no DHCP).
  #   ensureProfiles.profiles = {
  #     br0 = {
  #       connection = {
  #         id = "br0";
  #         type = "bridge";
  #         interface-name = "br0";
  #         autoconnect = true;
  #       };
  #       ipv4 = { method = "auto"; };
  #       ipv6 = { method = "ignore"; };
  #       bridge = { stp = false; };
  #     };

  #     br0-slave-eno1 = {
  #       connection = {
  #         id = "br0-slave-eno1";
  #         type = "ethernet";
  #         interface-name = "eno1";
  #         master = "br0";
  #         slave-type = "bridge";
  #         autoconnect = true;
  #       };
  #       ipv4 = { method = "disabled"; };
  #       ipv6 = { method = "ignore"; };
  #     };
  #   };
  # };
}
