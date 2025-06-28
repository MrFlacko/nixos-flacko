{ config, pkgs, ... }:

{
  # make sure the USB-audio driver is present (it’s built-in on the default kernel,
  # but declaring it guarantees it loads early).
  boot.kernelModules = [ "snd_usb_audio" ];

  # your existing pipewire section …
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # optional: tools like aplay/pw-cli for troubleshooting
  environment.systemPackages = with pkgs; [ alsa-utils pipewire wireplumber ];

  users.users.flacko.extraGroups = [ "audio" ];
}