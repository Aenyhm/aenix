{
  flake.nixosModules.plasma = { pkgs, ... }: {
  services.desktopManager.plasma6.enable = true;

  environment.plasma6.excludePackages =
    with pkgs.kdePackages; [
      discover
      elisa
      kate
      qrca
    ];
  };
}
