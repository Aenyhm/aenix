{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  # One Syncthing per user, as a user service, so every session syncs its own folders
  flake.modules.nixos.syncthing = {
    networking.firewall = {
      allowedTCPPorts = [ 22000 ];
      allowedUDPPorts = [
        22000
        21027
      ];
    };
    home-manager.sharedModules = [ hm.syncthing ];
  };

  flake.modules.homeManager.syncthing = { pkgs, ... }: {
    services.syncthing = {
      enable = true;
      # Devices and folders are managed in the GUI, a rebuild must not delete them
      overrideDevices = false;
      overrideFolders = false;
      tray = {
        enable = true;
        package = pkgs.syncthingtray; # the full Qt app, needed while configuring it
      };
    };
  };
}
