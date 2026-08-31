{ inputs, self, ... }:

{
  # TODO when ready
  #
  # flake.nixosConfigurations.work =
  #   inputs.nixpkgs.lib.nixosSystem {
  #     system = "x86_64-linux";

  #     specialArgs = {
  #       inherit inputs self;
  #     };

  #     modules = [
  #       self.nixosModules.work
  #     ];
  #   };
}
