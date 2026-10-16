{
  flake.modules.nixos.work-hardware = { inputs, modulesPath, ... }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
      # Dell Pro 14 PC14250 has no model of its own in nixos-hardware: Intel CPU and GPU, laptop, SSD
      inputs.nixos-hardware.nixosModules.common-cpu-intel
      inputs.nixos-hardware.nixosModules.common-pc-laptop
      inputs.nixos-hardware.nixosModules.common-pc-ssd
    ];
    # Paste the hardware configuration generated on the work machine here.
  };
}
