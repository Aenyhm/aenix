{ ... }:

{
  flake.nixosModules.home-hardware =
    { config, lib, pkgs, modulesPath, ... }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];

      boot.initrd.kernelModules = [ ];

      boot.kernelModules = [ ];

      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device =
          "/dev/disk/by-uuid/d0a011b4-53d1-46de-93f3-8cce69740de7";

        fsType = "btrfs";
      };

      fileSystems."/home" = {
        device =
          "/dev/disk/by-uuid/d0a011b4-53d1-46de-93f3-8cce69740de7";

        fsType = "btrfs";

        options = [
          "subvol=home"
        ];
      };

      fileSystems."/nix" = {
        device =
          "/dev/disk/by-uuid/d0a011b4-53d1-46de-93f3-8cce69740de7";

        fsType = "btrfs";

        options = [
          "subvol=nix"
        ];
      };

      fileSystems."/boot" = {
        device =
          "/dev/disk/by-uuid/F7CA-3A33";

        fsType = "vfat";

        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      swapDevices = [
        {
          device =
            "/dev/disk/by-uuid/02fd32f9-3c4c-4f31-9e0d-0df4a019a5e3";
        }
      ];

      nixpkgs.hostPlatform =
        lib.mkDefault "x86_64-linux";

      hardware.cpu.intel.updateMicrocode =
        lib.mkDefault
          config.hardware.enableRedistributableFirmware;
    };
}
