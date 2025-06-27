#!/bin/bash

rm -r /etc/nixos/*
cp -ra /home/flacko/.config/nix-config/* /etc/nixos/

chown -R root:root /etc/nixos

# Set directory and file permissions properly
find /etc/nixos -type d -exec chmod 755 {} \;
find /etc/nixos -type f -exec chmod 644 {} \;

# Set permissions for scripts directory explicitly
chmod 750 /etc/nixos/scripts
chmod 750 /etc/nixos/scripts/*.sh
chown root:users /etc/nixos/scripts
chown root:users /etc/nixos/scripts/*.sh

chmod +x /etc/nixos/setup/*.sh

nixos-rebuild switch --log-format bar