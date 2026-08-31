{
  flake.nixosModules.boot = { ... }: {
    boot.loader = {
      efi.canTouchEfiVariables = true;

      grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
      };
    };
  };
}
