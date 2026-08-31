{ inputs, pkgs, ... }:

let
  unstable =
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.packages = [
    unstable.faugus-launcher
    #pkgs.protonplus
  ];

  programs.mangohud = {
    enable = true;

    # cf. https://raw.githubusercontent.com/flightlessmango/MangoHud/master/data/MangoHud.conf
    settings = {
      vsync = 1; # 0 = adaptive; 1 = off; 2 = mailbox; 3 = on
      fps_limit = 160;
      frametime = false;
      frame_timing = false;
      cpu_stats = true;
      gpu_stats = true;
      fps = true;
      gamemode = true;
      wine = true; # Show Proton version
      toggle_hud = "Shift_L+F12";
      no_display = true; # Hidden by default
    };
  };

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "\${HOME}/.steam/root/compatibilitytools.d";
  };
}
