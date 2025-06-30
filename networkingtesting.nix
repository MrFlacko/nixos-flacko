{ config, pkgs, ... }:

{
  ## Attempting to set up myself
  nixpkgs.config.allowUnfree = true;
  services.resolved.enable = true;
  services.dbus.enable = true;
  networking.firewall.checkReversePath = false;

  environment.systemPackages = with pkgs; [
    dhcpcd
    mtr whois nmap bind.dnsutils tcpdump iperf3 ethtool bmon wireshark # Some nice networking tools
  ];

  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;
}