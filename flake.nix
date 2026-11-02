{
  description = "AeNix";

  inputs = {
    # The NixOS release: change nixpkgs and home-manager together (docs/how-to.md)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Structure: every file under modules/ is a flake-parts module
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    # Private values and the modules of the work laptop, fetched over SSH with the personal key
    # of the github-aenyhm alias (modules/apps/ssh.nix)
    private = {
      url = "git+ssh://git@github-aenyhm/Aenyhm/aenix-private";
      flake = false;
    };

    # Packages and modules from outside nixpkgs
    # Source only: its own flake builds Cowork's QEMU with options missing from stable nixpkgs
    claude-desktop = {
      url = "github:danielbodart/claude-desktop";
      flake = false;
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        (inputs.import-tree ./modules)
        (inputs.import-tree "${inputs.private}/modules")
      ];
    };
}
