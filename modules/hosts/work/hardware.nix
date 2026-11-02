{
  flake.modules.nixos.work-hardware =
    {
      config,
      inputs,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
        # The laptop has no model of its own in nixos-hardware: Intel CPU and GPU, laptop, SSD
        inputs.nixos-hardware.nixosModules.common-cpu-intel
        inputs.nixos-hardware.nixosModules.common-pc-laptop
        inputs.nixos-hardware.nixosModules.common-pc-ssd
      ];

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "vmd"
        "nvme"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/mapper/luks-760a6900-fcc1-47da-93ef-4462b43151f8";
        fsType = "btrfs";
      };

      boot.initrd.luks.devices."luks-760a6900-fcc1-47da-93ef-4462b43151f8".device =
        "/dev/disk/by-uuid/760a6900-fcc1-47da-93ef-4462b43151f8";
      boot.initrd.luks.devices."luks-db277d93-5809-4e1f-97ae-03a46e4c5d8a".device =
        "/dev/disk/by-uuid/db277d93-5809-4e1f-97ae-03a46e4c5d8a";

      fileSystems."/home" = {
        device = "/dev/mapper/luks-760a6900-fcc1-47da-93ef-4462b43151f8";
        fsType = "btrfs";
        options = [ "subvol=home" ];
      };

      fileSystems."/nix" = {
        device = "/dev/mapper/luks-760a6900-fcc1-47da-93ef-4462b43151f8";
        fsType = "btrfs";
        options = [ "subvol=nix" ];
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/DCBC-62F0";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      swapDevices = [
        { device = "/dev/mapper/luks-db277d93-5809-4e1f-97ae-03a46e4c5d8a"; }
      ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
