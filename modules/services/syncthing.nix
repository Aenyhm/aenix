{
  flake.nixosModules.syncthing =
    { config, lib, ... }:
    let
      user = config.aenix.user.name;
      home = config.users.users.${user}.home;
    in
    {
      services.syncthing = {
        enable = true;

        user = user;
        group = "users";

        dataDir = home;
        configDir = "${home}/.config/syncthing";

        guiAddress = "127.0.0.1:8384";

        openDefaultPorts = true;
      };
    };
}
