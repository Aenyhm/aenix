{
  flake.nixosModules.gaming-performance = { ... }: {
    programs.gamescope = {
      enable = true;
    };

    programs.gamemode = {
      enable = true;

      # Keep default true: allows GameMode to renice processes.
      enableRenice = true;
    };
  };
}
