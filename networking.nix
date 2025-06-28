{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # Proton GUI talks to NetworkManager + systemd-resolved
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
  };
  services.resolved.enable = true;

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
    mtr whois nmap bind.dnsutils tcpdump iperf3 ethtool bmon wireshark # Some nice networking tools
  ];

  programs.wireshark.enable = true;
  programs.wireshark.dumpcap.enable = true; 
  programs.wireshark.usbmon.enable  = false; 
}