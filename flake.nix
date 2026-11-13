{
  description = "AeNix";

  inputs = {
    # Change together with the home-manager release (docs/how-to.md)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    # Fetched over SSH through the github-aenyhm alias
    private = {
      url = "git+ssh://git@github-aenyhm/Aenyhm/aenix-private";
      flake = false;
    };

    # Source only: its flake builds Cowork's QEMU, which is disabled
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
