{
  flake.nixosModules.audio = { ... }: {
    services.pulseaudio.enable = false;
    security.rtkit.enable = false; # doesn't work with Mumble
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
