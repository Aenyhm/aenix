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
  # fnouaillat, the work user, on work and as a backup session on home
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
        "org.kde.dolphin"
        "obsidian"
        "dev.zed.Zed"
        "pgadmin"
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
      home.packages = with pkgs; [
        # Official .deb, repackaged. Without Cowork, the agent that works in a QEMU virtual machine
        (callPackage "${inputs.claude-desktop}/package.nix" { withCowork = false; })
        awscli2
        dbeaver-bin
        delve
        go
        jetbrains.pycharm
        opentofu
        postgresql
        slack
        ssm-session-manager-plugin # aws ssm start-session, used by the bastion tunnel
        terragrunt
        uv
      ];
      # Claude Code comes from its official installer, which keeps it up to date in ~/.local/bin.

      # pgAdmin, for its graphical EXPLAIN and its completion: its server runs in the background
      # on 127.0.0.1:5050, and its launcher opens it in a Brave window without tabs or address bar
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

      # ~/sync/work is the work Syncthing folder: notes, scripts, the Claude Code config and the
      # work secrets (.env files, AWS profiles). Its .stignore keeps the history and sessions of
      # ~/.claude on each machine
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

      # Work scripts and aliases
      home.sessionPath = [ "$HOME/sync/work/scripts" ];
      home.sessionVariables.PYTHONDONTWRITEBYTECODE = "1";
      programs.bash.initExtra = ''
        if [ -f ~/sync/work/scripts/aliases.sh ]; then . ~/sync/work/scripts/aliases.sh; fi
        # Node.js, vp and vpr come from vite-plus, installed by its own script (esgc-front README)
        if [ -f ~/.config/vite-plus/env ]; then . ~/.config/vite-plus/env; fi
      '';
    };
}
