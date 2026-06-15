{ config, lib, pkgs, modulesPath, cmod, ... }:
/*
  Prism Launcher wrapper

  Why this exists:
  - Prism Launcher is installed from nixos-unstable because stable is too old.
  - When Prism opens folders it launches KDE applications (kde-open, dolphin).
  - The unstable Prism runtime leaks Qt/glibc environment variables into child processes.
  - Stable KDE applications then crash with:
      GLIBC_ABI_DT_X86_64_PLT not found

  Fix:
  - fakeKdeOpen provides replacement kde-open and kde-open6 commands.
  - Before launching Dolphin, we remove the problematic Qt/Nix library variables.
  - prismFixed puts fakeKdeOpen first in PATH so only Prism sees the replacements.
  - The rest of the system continues using the normal KDE tools.

  Result:
  - Prism 11 from unstable.
  - Dolphin opens correctly from Prism.
  - No global system modifications.
*/

let
  unstable = import <nixos-unstable> {};

  cleanEnv = ''
    unset QT_PLUGIN_PATH
    unset QML2_IMPORT_PATH
    unset NIXPKGS_QT6_QML_IMPORT_PATH
    unset LD_LIBRARY_PATH
    unset NIX_LD
    unset NIX_LD_LIBRARY_PATH

    exec ${pkgs.kdePackages.dolphin}/bin/dolphin "$@"
  '';

  fakeKdeOpen = pkgs.symlinkJoin {
    name = "fake-kde-open";
    paths = [
      (pkgs.writeShellScriptBin "kde-open" cleanEnv)
      (pkgs.writeShellScriptBin "kde-open6" cleanEnv)
    ];
  };

  prismFixed = pkgs.writeShellScriptBin "prismlauncher" ''
    export PATH=${pkgs.lib.makeBinPath [
      fakeKdeOpen
      pkgs.coreutils
      pkgs.xdg-utils
      pkgs.kdePackages.dolphin
    ]}

    exec ${unstable.prismlauncher}/bin/prismlauncher "$@"
  '';
in
{
  environment.systemPackages = [
    prismFixed

    (pkgs.makeDesktopItem {
      name = "prismlauncher";
      desktopName = "Prism Launcher";
      comment = "Minecraft launcher";
      exec = "prismlauncher";
      icon = "${unstable.prismlauncher}/share/icons/hicolor/scalable/apps/org.prismlauncher.PrismLauncher.svg";
      categories = [ "Game" ];
    })
  ];
}