{ config, lib, pkgs, modulesPath, cmod, ... }:
{
  boot.kernelModules = [ "snd_usb_audio" ];

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # Vesktop
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];

  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa.enable = true; 
    alsa.support32Bit = true;

    wireplumber = {
      enable = true;
      extraConfig."99-disable-suspend" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "node.name" = "~alsa_input.*"; }
              { "node.name" = "~alsa_output.*"; }
            ];
            actions.update-props = {
              "session.suspend-timeout-seconds" = 0;
            };
          }
        ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    pipewire
    wireplumber
    # easyeffects
  ];
}