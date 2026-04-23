{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

## Programs
  programs.wireshark.enable = true;
  programs.wireshark.dumpcap.enable = true;
  programs.wireshark.usbmon.enable = false;
  services.resolved.enable = true;
  services.dbus.enable = true;

  environment.systemPackages = with pkgs; [ 
    wireguard-tools iptables networkmanager-openvpn mtr whois nmap 
    bind.dnsutils tcpdump iperf3 ethtool bmon

    wgnord jq curl wireguard-tools openresolv
  ];

## Network Manager Setup
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    plugins = with pkgs; [ networkmanager-openvpn ];
    settings.main.no-auto-default = "*"; # Stop auto starting default
    settings.dhcp.dhcp-client-id = "mac"; # Force mac dhcp client

    ensureProfiles.profiles = {
      br0 = {
        connection.id = "br0";
        connection.type = "bridge";
        connection.interface-name = "br0";
        connection.autoconnect = true;
  
        bridge.stp = false;
        bridge.mac-address = "18:C0:4D:2E:47:70";
  
        ipv4.method = "auto";
        # ipv4.dns = "162.252.172.57;149.154.159.92"; #Surfshark
        ipv4.dns = "103.86.96.100;103.86.99.100"; #NordVPN
        
        ipv6.method = "ignore";

      };
  
      eno1 = {
        connection.id = "eno1";
        connection.type = "ethernet";
        connection.interface-name = "eno1";
        connection.master = "br0";
        connection.slave-type = "bridge";
        connection.autoconnect = true;
  
        ipv4.method = "disabled";
        ipv6.method = "ignore";
      };
    };
  };

  ## Firewall Setup
  networking.firewall = {
    trustedInterfaces = [ "br0" ];
    checkReversePath = false;
  
    allowedTCPPorts = [
      47989 # Sunshine control
      47984 # Sunshine web UI / pairing
      8080
      48010 # Sunshine session/aux TCP
      80 # Web
    ];
  
    allowedUDPPortRanges = [
      { from = 47998; to = 48010; } # Sunshine streaming
      { from = 8000; to = 9000;  } # Parsec
      { from = 16261; to = 16262; } # Zomboid
    ];
  };

  # Enable IP forwarding for VM traffic
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
  
  boot.kernelModules = [ "wireguard" ];
  systemd.services.NetworkManager-wait-online.enable = false;
}