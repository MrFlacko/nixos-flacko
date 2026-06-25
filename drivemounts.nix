{ config, pkgs, cmod, lib, ... }:

{
  fileSystems."/mnt/Games" = {
    device  = "/dev/disk/by-uuid/d02588e1-9d3c-4dba-9346-13cfb8a6fe7d"; # <- new UUID
    fsType  = "ext4";
    options = [ "noatime" "nofail" "x-systemd.automount" "x-systemd.device-timeout=20"];
  };

  # 8 TB HDD “I Was Here”
  fileSystems."/mnt/8TBDrive" = {
    device  = "/dev/disk/by-uuid/F272D58C72D55647";   # /dev/sdd1
    fsType  = "ntfs";
    options = [ "uid=1000" "gid=100" "windows_names" "big_writes" "fmask=0000" "dmask=0000"];
  };

  # 500GB SSD "LinuxGames"
  #fileSystems."/mnt/LinuxGames" = {
  #  device  = "/dev/disk/by-uuid/4590010d-17ac-4e5d-a1ca-4e03b0777221";
  #  fsType  = "ext4";
  #  options = [ "noatime" ];
  #};

  # # 2 TB HDD
  # #   sudo mkfs.ext4 -L Data2TB /dev/sdb1
  # fileSystems."/mnt/Data2TB" = {
  #   device  = "/dev/disk/by-label/Data2TB";           # /dev/sdb1
  #   fsType  = "ext4";
  #   options = [ "noatime" ];
  # }; 
}