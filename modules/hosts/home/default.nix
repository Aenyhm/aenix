{
  config,
  inputs,
  private,
  ...
}:
let
  inherit (config.flake.modules) nixos;
in
{
  flake.modules.nixos.host-home = { config, lib, ... }: {
    imports = with nixos; [
      home-hardware
      boot
      base
      nix
      home-manager
      desktop
      syncthing
      docker
      gaming
      nas-music
      aenyhm
      fnouaillat
    ];

    networking.hostName = "aenyhm-home-linux";
    # nixpkgs release of the first install. Never change it, even after upgrading nixpkgs: see docs/how-to.md
    system.stateVersion = "26.05";

    hardware.graphics.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      open = true; # required for modern GPUs
      powerManagement.enable = true;
      # Newest driver rather than the production branch: fixes and gains for recent games
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
    # sched-ext scheduler, as on CachyOS: games keep the CPU when other programs load it
    services.scx = {
      enable = true;
      scheduler = "scx_lavd";
    };
    # Windows dual boot
    time.hardwareClockInLocalTime = true; # Windows keeps the RTC in local time
    boot.loader.grub.useOSProber = true;

    # Backup work session, without the company agents that would monitor the whole machine.
    # Its name on the login screen only, git reads aenix.users
    users.users.fnouaillat.description = lib.mkForce private.workName;

    # Both sessions can be open at once, the second Syncthing needs its own ports
    home-manager.users.fnouaillat.services.syncthing = {
      guiAddress = "127.0.0.1:8385";
      settings.options.listenAddresses = [
        "tcp://:22001"
        "quic://:22001"
        "dynamic+https://relays.syncthing.net/endpoint"
      ];
    };
    networking.firewall = {
      allowedTCPPorts = [ 22001 ];
      allowedUDPPorts = [ 22001 ];
    };
    # Dolphin shows a USB-connected iPhone (photos, app files) once it trusts this computer
    services.usbmuxd.enable = true;
  };

  flake.nixosConfigurations.aenyhm-home-linux = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [ nixos.host-home ];
  };
}
