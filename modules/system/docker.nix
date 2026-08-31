{
  # Docker for fnouaillat, who gets the docker group in modules/users/fnouaillat.nix
  flake.modules.nixos.docker = {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = false; # the daemon starts at the first docker command
    };

    # arm64 images run through QEMU. The static emulator stays reachable from inside the containers,
    # and NixOS registers it at each boot, so docker run tonistiigi/binfmt is no longer needed
    boot.binfmt = {
      emulatedSystems = [ "aarch64-linux" ];
      preferStaticEmulators = true;
    };
  };
}
