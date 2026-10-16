{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.nixos.home-manager =
    {
      config,
      inputs,
      lib,
      ...
    }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        # A file home-manager takes over (mimeapps.list written by KDE) is renamed instead of failing the switch
        backupFileExtension = "backup";
        extraSpecialArgs = { inherit inputs; };
        users = lib.mapAttrs (_: user: { imports = [ hm.base ] ++ user.homeModules; }) config.aenix.users;
      };
    };

  # home.username and home.homeDirectory come from the NixOS user
  flake.modules.homeManager.base = { osConfig, ... }: {
    home.stateVersion = osConfig.system.stateVersion;
  };
}
