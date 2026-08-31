{
  flake.nixosModules.steam = { ... }: {
    programs.steam = {
      enable = true;

      gamescopeSession.enable = false;

      protontricks.enable = true;

      # Steam Remote Play
      remotePlay.openFirewall = true;

      dedicatedServer.openFirewall = false;
    };
  };
}
