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
        "dev.zed.Zed"
        "obsidian"
        defaultBrowser
        "spotify"
        "signal"
        "info.mumble.Mumble"
        "steam"
        "io.github.Faugus.faugus-launcher"
      ];
    };
  };

  flake.modules.homeManager.aenyhm = { pkgs, ... }: {
    home.packages = with pkgs; [
      audacity
      element-desktop
      mumble
      signal-desktop
      soundconverter
    ];

    programs.zed-editor.extensions = [
      "c3"
      "odin"
    ];
  };
}
