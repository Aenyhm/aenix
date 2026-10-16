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

    # Private values (emails, Wazuh manager), fetched over SSH: build as the user (nh, or nixos-rebuild --sudo)
    private = {
      url = "git+ssh://git@github.com/Aenyhm/aenix-private";
      flake = false;
    };

    # Packages and modules from outside nixpkgs
    # Source only: its own flake builds Cowork's QEMU with options missing from stable nixpkgs
    claude-desktop = {
      url = "github:danielbodart/claude-desktop";
      flake = false;
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-vanta = {
      url = "github:taho-inc/nixos-vanta";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
