{ config, inputs, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  flake.modules.nixos.host-work = {
    imports = with nixos; [
      work-hardware
      boot
      base
      nix
      home-manager
      desktop
      syncthing
      docker
      company
      nas-music
      fnouaillat
    ];
    networking.hostName = "fnouaillat-work";
    # sched-ext scheduler: the desktop stays responsive while a test run loads every core.
    # --autopower follows the power profile KDE sets (performance on AC, powersave on battery)
    services.scx = {
      enable = true;
      scheduler = "scx_lavd";
      extraArgs = [ "--autopower" ];
    };
    # nixpkgs release of flake.nix at the first install. Never change it afterwards: see docs/how-to.md
    system.stateVersion = "26.05";
  };

  # TODO when work-hardware is filled in
  # flake.nixosConfigurations.fnouaillat-work = inputs.nixpkgs.lib.nixosSystem {
  #   specialArgs = { inherit inputs; };
  #   modules = [ nixos.host-work ];
  # };
}
