{
  flake.nixosModules.home = { config, inputs, self, ... }: {
    imports = [
      self.nixosModules.home-hardware

      self.nixosModules.boot
      self.nixosModules.dualboot-windows

      self.nixosModules.base
      self.nixosModules.nix
      self.nixosModules.zswap
      self.nixosModules.networking
      self.nixosModules.audio
      self.nixosModules.bluetooth
      self.nixosModules.printing

      self.nixosModules.nvidia

      self.nixosModules.sddm
      self.nixosModules.plasma

      self.nixosModules.syncthing
      self.nixosModules.steam
      self.nixosModules.gaming-performance

      inputs.home-manager.nixosModules.home-manager
    ];

    aenix.user.name = "aenyhm";
    networking.hostName = "aenyhm-home-linux";

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      extraSpecialArgs = {
        inherit inputs;
      };

      users.${config.aenix.user.name} = import ../../../home/home.nix;
    };
  };
}
