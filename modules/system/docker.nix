{
  flake.modules.nixos.docker = {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = false; # the daemon starts at the first docker command
    };

    # Runs arm64 images through QEMU. NixOS registers the static emulator at boot, reachable from
    # containers, so tonistiigi/binfmt is not needed
    boot.binfmt = {
      emulatedSystems = [ "aarch64-linux" ];
      preferStaticEmulators = true;
    };
  };
}
