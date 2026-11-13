{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
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
      # Devices and folders are set in the GUI, a rebuild keeps them
      overrideDevices = false;
      overrideFolders = false;
      tray = {
        enable = true;
        package = pkgs.syncthingtray; # the full Qt app, needed while configuring it
      };
    };
  };
}
