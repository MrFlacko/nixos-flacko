{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # Proton GUI talks to NetworkManager + systemd-resolved
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    plugins = [ 
      pkgs.networkmanager-openvpn 
    ];
  };
  services.resolved.enable = true;
  services.dbus.enable = true;

  # Disable reverse-path filtering – without this the tunnel
  # comes up, packets get dropped, the client reconnects forever.
  networking.firewall.checkReversePath = false;

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.rp_filter" = 2;
    "net.ipv4.conf.default.rp_filter" = 2;
  };

  environment.systemPackages = with pkgs; [
    protonvpn-gui
    wireguard-tools
    iptables
    networkmanager-openvpn
    mtr whois nmap bind.dnsutils tcpdump iperf3 ethtool bmon wireshark # Some nice networking tools
  ];

  # might be better https://wiki.nixos.org/wiki/Mtr
  #
  # programs.mtr.enable = true;
  # services.mtr-exporter.enable = true;

  ## Extra Hosts 
  networking.extraHosts = ''
    172.16.0.10 watch.flacko.net
    172.16.0.10 status.flacko.net
    172.16.0.10 request.flacko.net
  '';

  boot.kernelModules = [ "wireguard" ];

  programs.wireshark.enable = true;
  programs.wireshark.dumpcap.enable = true; 
  programs.wireshark.usbmon.enable  = false; 
}