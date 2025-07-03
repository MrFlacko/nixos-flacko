{ config, pkgs, ... }:

{
  boot.kernelModules = [ "snd_usb_audio" ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;

    wireplumber = {
      enable = true;
      extraConfig."99-disable-suspend" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "node.name" = "~alsa_input.*"; }
              { "node.name" = "~alsa_output.*"; }
            ];
            actions.update-props = { "session.suspend-timeout-seconds" = 0; };
          }
        ];
      };
    };
  };

  environment.systemPackages = with pkgs; [ pipewire wireplumber ];
}