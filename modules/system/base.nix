{
  flake.nixosModules.base =
    { config, lib, pkgs, ... }:
    let
      cfg = config.aenix.user;
    in
    {
      options.aenix.user.name = lib.mkOption {
        type = lib.types.str;
        description = "Primary user for this host.";
      };

      config = {
        users.users.${cfg.name} = {
          isNormalUser = true;
          extraGroups = [
            "networkmanager"
            "wheel"
          ];
        };

        time.timeZone = "Europe/Paris";

        i18n.defaultLocale = "fr_FR.UTF-8";

        # i18n.extraLocaleSettings = {
        #   LC_ADDRESS = "fr_FR.UTF-8";
        #   LC_IDENTIFICATION = "fr_FR.UTF-8";
        #   LC_MEASUREMENT = "fr_FR.UTF-8";
        #   LC_MONETARY = "fr_FR.UTF-8";
        #   LC_NAME = "fr_FR.UTF-8";
        #   LC_NUMERIC = "fr_FR.UTF-8";
        #   LC_PAPER = "fr_FR.UTF-8";
        #   LC_TELEPHONE = "fr_FR.UTF-8";
        #   LC_TIME = "fr_FR.UTF-8";
        # };

        services.xserver.xkb = {
          layout = "fr";
          variant = "oss";
        };

        console.keyMap = "fr";

        nixpkgs.config.allowUnfree = true;

        fonts.packages = with pkgs; [
          nerd-fonts.jetbrains-mono
          noto-fonts-color-emoji
        ];

        xdg.portal.enable = true;

        system.stateVersion = "26.05";
      };
    };
}
