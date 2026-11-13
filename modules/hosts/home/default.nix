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
      kde
      syncthing
      docker
      gaming
      nas-music
      aenyhm
      fnouaillat
    ];

    networking.hostName = "aenyhm-home-linux";
    # Never change it: docs/how-to.md, Upgrade NixOS
    system.stateVersion = "26.05";

    hardware.graphics.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      open = true; # required for modern GPUs
      powerManagement.enable = true;
      # Latest driver, not production: fixes for recent games
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
    # Motherboard fan and pump sensors (NCT6798), not loaded automatically
    boot.kernelModules = [ "nct6775" ];
    # sched-ext scheduler, as on CachyOS: games keep the CPU when other programs load it
    services.scx = {
      enable = true;
      scheduler = "scx_lavd";
    };
    time.hardwareClockInLocalTime = true; # Windows keeps the RTC in local time
    boot.loader.grub.useOSProber = true;

    # Backup work session, without the company agents, which would monitor the whole machine.
    # Sets only the login screen name; git reads aenix.users
    users.users.fnouaillat.description = lib.mkForce private.workName;

    # Both sessions can run at once, so this Syncthing needs other ports
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
    # Lets the file manager open a USB iPhone once it trusts this computer
    services.usbmuxd.enable = true;
  };

  flake.nixosConfigurations.aenyhm-home-linux = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [ nixos.host-home ];
  };
}
