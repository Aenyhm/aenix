{
  flake.nixosModules.sddm = { ... }: {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;

      settings.General.RememberLastSession = true;
    };
  };
}
