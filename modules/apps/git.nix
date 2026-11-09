{ config, ... }:
{
  flake.modules.homeManager.apps.imports = [ config.flake.modules.homeManager.git ];

  # user.name and user.email come from the host: aenix.users on NixOS, the mac host on macOS
  flake.modules.homeManager.git = {
    programs.gh.enable = true; # also the git credential helper for github.com
    programs.git = {
      enable = true;
      ignores = [ "**/.claude/settings.local.json" ];
      settings = {
        alias = {
          ci = "commit";
          co = "checkout";
          st = "status";
          ca = "commit --amend";
          cn = "commit --amend --no-edit";
          pf = "push --force-with-lease";
          # Deletes the local branches whose remote is gone ("disparue" with a French locale)
          branches-clear = "!git branch -vv | awk '/: (gone|disparue)]/{print $1}' | xargs -r git branch -D";
        };
        push.autoSetupRemote = true;
        fetch.prune = true;
        # After a force push, only the local commits made since are replayed on the new remote
        pull.rebase = true;
      };
    };
  };
}
