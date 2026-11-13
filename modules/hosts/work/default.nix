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
      kde
      syncthing
      docker
      company
      nas-music
      fnouaillat
    ];
    networking.hostName = "fnouaillat-work";
    # sched-ext scheduler: the desktop stays responsive while tests load every core.
    # --autopower follows the power profile (performance on AC, powersave on battery)
    services.scx = {
      enable = true;
      scheduler = "scx_lavd";
      extraArgs = [ "--autopower" ];
    };
    # Never change it: docs/how-to.md, Upgrade NixOS
    system.stateVersion = "26.05";
  };

  flake.nixosConfigurations.fnouaillat-work = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [ nixos.host-work ];
  };
}
