{
  flake.nixosModules.nvidia = { ... }: {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    services.xserver.videoDrivers = [
      "nvidia"
    ];

    hardware.nvidia = {
      modesetting.enable = true;

      powerManagement.enable = true;
      powerManagement.finegrained = false;

      # Required/appropriate for modern supported GPUs.
      open = true;

      # Newest NVIDIA branch available in this nixpkgs revision.
      branch = "latest";

      nvidiaSettings = true;
    };
  };
}
