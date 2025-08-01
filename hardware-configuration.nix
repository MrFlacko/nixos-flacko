# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "ntfs" ];

  swapDevices = [ { device = "/dev/disk/by-uuid/5311896b-fede-4e76-80b0-cc629e42a441"; } ];

  # Root Filesystem NVMe SSD
  fileSystems."/" = { 
    device = "/dev/disk/by-uuid/c8a3b086-d3ca-4958-9a0d-38a5afe318ea";
    fsType = "ext4";
  };

  # Boot Filesystem
  fileSystems."/boot" = { 
      device = "/dev/disk/by-uuid/8DA1-AAA2";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ]; 
  };

  # 500GB SSD "LinuxGames"
  fileSystems."/mnt/LinuxGames" = {
    device  = "/dev/disk/by-uuid/4590010d-17ac-4e5d-a1ca-4e03b0777221";
    fsType  = "ext4";
    options = [ "noatime" ];
  };

  # 1 TB SSD “Games”
  fileSystems."/mnt/Games" = {
    device  = "/dev/disk/by-uuid/42ACD2E1ACD2CE93";   # /dev/sdc1
    fsType  = "ntfs";
    options = [ "uid=1000" "gid=100" "windows_names" "big_writes" "fmask=0000" "dmask=0000"];
  };

  # 8 TB HDD “I Was Here”
  fileSystems."/mnt/8TBDrive" = {
    device  = "/dev/disk/by-uuid/F272D58C72D55647";   # /dev/sdd1
    fsType  = "ntfs";
    options = [ "uid=1000" "gid=100" "windows_names" "big_writes" "fmask=0000" "dmask=0000"];
  };

  # # 2 TB HDD
  # #   sudo mkfs.ext4 -L Data2TB /dev/sdb1
  # fileSystems."/mnt/Data2TB" = {
  #   device  = "/dev/disk/by-label/Data2TB";           # /dev/sdb1
  #   fsType  = "ext4";
  #   options = [ "noatime" ];
  # }; 

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
  # networking.interfaces.proton0.useDHCP = lib.mkDefault true;
  # networking.interfaces.pvpnksintrf0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
