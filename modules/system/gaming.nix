{
  flake.modules.nixos.gaming = { pkgs, ... }: {
    # Steam also enables 32-bit graphics and audio
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      # Proton-GE, offered in each game's compatibility settings and updated with the system
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };
    programs.gamescope.enable = true;
    programs.gamemode.enable = true;
  };

  flake.modules.homeManager.gaming =
    { pkgs, ... }:
    {
      home.packages = [
        # Launchers
        pkgs.unstable.faugus-launcher # TODO: back to stable once it has 2.x, 26.05 is still on 1.22
        pkgs.protontricks

        # Games
        pkgs.neverball
      ];

      # cf. https://raw.githubusercontent.com/flightlessmango/MangoHud/master/data/MangoHud.conf
      programs.mangohud = {
        enable = true;
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
    };
}
