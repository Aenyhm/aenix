{
  config,
  private,
  defaultBrowser,
  ...
}:
let
  hm = config.flake.modules.homeManager;
in
{
  # aenyhm, the personal user, on home
  flake.modules.nixos.aenyhm = {
    aenix.users.aenyhm = {
      fullName = "Aenyhm";
      email = private.emails.aenyhm;
      homeModules = with hm; [
        apps
        aenyhm
        gaming
      ];
      launchers = [
        "com.mitchellh.ghostty"
        "org.kde.dolphin"
        "dev.zed.Zed"
        "obsidian"
        defaultBrowser
        "signal"
        "info.mumble.Mumble"
        "spotify"
        "steam"
        "io.github.Faugus.faugus-launcher"
      ];
    };
  };

  flake.modules.homeManager.aenyhm = { pkgs, ... }: {
    home.packages = with pkgs; [
      # Communications
      signal-desktop
      element-desktop
      mumble

      # Audio
      audacity
      soundconverter
    ];
  };
}
