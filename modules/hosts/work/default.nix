{ config, inputs, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  flake.modules.nixos.host-work = { config, ... }: {
    imports = with nixos; [
      work-hardware
      boot
      base
      nix
      home-manager
      desktop
      syncthing
      docker
      vanta
      wazuh
      nas-music
      fnouaillat
    ];
    networking.hostName = "fnouaillat-work";
    # nixpkgs release of flake.nix at the first install. Never change it afterwards: see docs/how-to.md
    system.stateVersion = "26.05";
    services.vanta.ownerEmail = config.aenix.users.fnouaillat.email;
  };

  # TODO when work-hardware is filled in
  # flake.nixosConfigurations.fnouaillat-work = inputs.nixpkgs.lib.nixosSystem {
  #   specialArgs = { inherit inputs; };
  #   modules = [ nixos.host-work ];
  # };
}
