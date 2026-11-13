{
  config,
  inputs,
  private,
  defaultBrowser,
  ...
}:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.nixos.fnouaillat = {
    aenix.users.fnouaillat = {
      fullName = "Fabien Nouaillat";
      email = private.emails.fnouaillat;
      homeModules = with hm; [
        apps
        fnouaillat
      ];
      launchers = [
        "com.mitchellh.ghostty"
        "obsidian"
        "dev.zed.Zed"
        defaultBrowser
        "slack"
      ];
    };
    users.users.fnouaillat.extraGroups = [ "docker" ];
  };

  flake.modules.homeManager.fnouaillat =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      # The default key is the work one, the personal one sits beside it
      programs.ssh.settings.github-aenyhm.identityFile = "~/.ssh/id_ed25519_aenyhm";

      home.packages = with pkgs; [
        # Official .deb, repackaged, without Cowork (an agent in a QEMU VM)
        (callPackage "${inputs.claude-desktop}/package.nix" { withCowork = false; })
        awscli2
        dbeaver-bin
        delve
        go
        opentofu
        postgresql
        slack
        ssm-session-manager-plugin # aws ssm start-session, used by the bastion tunnel
        terragrunt
        uv
      ];

      # pgAdmin, for its graphical EXPLAIN and completion. Its server runs on 127.0.0.1:5050, and its
      # launcher opens it in a Brave app window
      systemd.user.services.pgadmin = {
        Unit.Description = "pgAdmin";
        Service.ExecStart = "${pkgs.pgadmin4-desktopmode}/bin/pgadmin4";
        Install.WantedBy = [ "default.target" ];
      };
      xdg.desktopEntries.pgadmin = {
        name = "pgAdmin";
        exec = "brave --app=http://127.0.0.1:5050";
        icon = "server-database";
        categories = [ "Development" ];
        # The class Brave gives its app window, so the taskbar groups it under this launcher
        settings.StartupWMClass = "brave-127.0.0.1__-Default";
      };

      # ~/sync/work is the work Syncthing folder, see docs/how-to.md
      home.file.".claude".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/sync/work/claude-config";
      home.activation.claudeConfigDir = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
        mkdir -p "$HOME/sync/work/claude-config"
      '';
      # SSO profiles, no credential: the SSO cache and tokens stay in ~/.aws/sso and ~/.aws/cli
      home.file.".aws/config".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/sync/work/env/aws-config";
      # Claude in Chrome, the extension Claude Code drives the browser with
      programs.brave.extensions = [ { id = "fcoeoabgfenejglbffodgkkbkcdhcgfn"; } ];

      home.sessionPath = [ "$HOME/sync/work/scripts" ];
      home.sessionVariables.PYTHONDONTWRITEBYTECODE = "1";
      programs.bash.initExtra = ''
        if [ -f ~/sync/work/scripts/aliases.sh ]; then . ~/sync/work/scripts/aliases.sh; fi
        # vite-plus, installed by its own script
        if [ -f ~/.config/vite-plus/env ]; then . ~/.config/vite-plus/env; fi
      '';
    };
}
