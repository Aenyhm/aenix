{ ... }:

{
  flake.nixosModules.work-hardware =
    { config, lib, pkgs, modulesPath, ... }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      # Paste the hardware configuration generated on the work machine here.
    };
}
