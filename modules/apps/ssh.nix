{ config, ... }:
{
  # github.com takes each session's default key. The github-aenyhm alias, which builds use to fetch
  # aenix-private, takes the personal key
  flake.modules.homeManager.apps.imports = [ config.flake.modules.homeManager.ssh ];

  flake.modules.homeManager.ssh = { lib, ... }: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "*".addKeysToAgent = "yes";
        "github.com" = {
          identityFile = "~/.ssh/id_ed25519";
          identitiesOnly = true;
        };
        "github-aenyhm" = {
          hostname = "github.com";
          user = "git";
          identityFile = lib.mkDefault "~/.ssh/id_ed25519";
          identitiesOnly = true;
        };
      };
    };
  };
}
