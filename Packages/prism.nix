{ config, lib, pkgs, modulesPath, cmod, ... }:
let
  unstable = import <nixos-unstable> {};
  prismFixed = pkgs.writeShellScriptBin "prismlauncher" ''
    unset QT_PLUGIN_PATH
    unset QML2_IMPORT_PATH
    unset NIXPKGS_QT6_QML_IMPORT_PATH
    exec ${unstable.prismlauncher}/bin/prismlauncher "$@"
  '';
in
{
  environment.systemPackages = [
    prismFixed
  ];
}