{
  flake.nixosModules.work = { config, inputs, self, ... }: {
    imports = [
      self.nixosModules.work-hardware

      self.nixosModules.boot

      self.nixosModules.base
      self.nixosModules.nix
      self.nixosModules.zswap
      self.nixosModules.networking
      self.nixosModules.audio
      self.nixosModules.bluetooth
      self.nixosModules.printing

      self.nixosModules.sddm
      self.nixosModules.plasma

      self.nixosModules.syncthing

      inputs.home-manager.nixosModules.home-manager
    ];

    aenix.user.name = "fnouaillat";
    networking.hostName = "fnouaillat-work";

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      extraSpecialArgs = {
        inherit inputs;
      };

      users.${config.aenix.user.name} = import ../../../home/work.nix;
    };
  };
}
