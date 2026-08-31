{
  flake.modules.homeManager.apps = { config, osConfig, ... }: {
    programs.gh.enable = true; # also the git credential helper for github.com
    programs.git = {
      enable = true;
      ignores = [ "**/.claude/settings.local.json" ];
      settings = {
        user = {
          name = osConfig.aenix.users.${config.home.username}.fullName;
          email = osConfig.aenix.users.${config.home.username}.email;
        };
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
      };
    };
  };
}
