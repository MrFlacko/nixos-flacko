{ config, lib, pkgs, modulesPath, cmod, ... }:
let
  unstable = import <nixos-unstable> {};
in
{
  environment.systemPackages = with pkgs; [
    unstable.prismlauncher
  ];
}