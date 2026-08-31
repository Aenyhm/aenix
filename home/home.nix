{ osConfig, ... }:

{
  imports = [
    ./common.nix

    ./services/syncthing.nix

    ./applications/common.nix
    ./applications/home.nix
    ./applications/gaming.nix
  ];

  home.username = osConfig.aenix.user.name;
  home.homeDirectory = "/home/${osConfig.aenix.user.name}";

  home.stateVersion = "26.05";
}
