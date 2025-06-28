{ config, pkgs, ... }:

{
  # make sure the USB-audio driver is present (it’s built-in on the default kernel,
  # but declaring it guarantees it loads early).
  boot.kernelModules = [ "snd_usb_audio" ];

  # your existing pipewire section …
  services.pipewire = {
    enable = true;
    alsa.enable        = true;   # this is the ALSA bridge
    alsa.support32Bit  = true;
    pulse.enable       = true;   # Pulse-compat server
  };

  # optional: tools like aplay/pw-cli for troubleshooting
  environment.systemPackages = with pkgs; [ alsa-utils pipewire ];

  users.users.flacko.extraGroups = [ "audio" ];
}