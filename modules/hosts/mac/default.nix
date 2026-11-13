{
  config,
  inputs,
  private,
  ...
}:
let
  inherit (config.flake.modules) darwin homeManager;
in
{
  # Nix leaves the second account alone: it only gets the shared apps
  flake.modules.darwin.host-mac =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.home-manager.darwinModules.home-manager ];

      nixpkgs.hostPlatform = "aarch64-darwin";
      networking.hostName = "aenyhm-mac";
      # Never change it, same rule as on NixOS
      system.stateVersion = 7;
      system.primaryUser = "fabien";

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      environment.systemPackages = [
        pkgs.bashInteractive
        pkgs.nh
      ];
      # brew after Nix in the PATH: Nix wins when both provide a command
      environment.systemPath = lib.mkAfter [ "${config.homebrew.prefix}/bin" ];
      # Allowed as login shell, set once with chsh (docs/install.md)
      environment.shells = [ pkgs.bashInteractive ];
      environment.variables.NH_FLAKE = "/Users/fabien/aenix";
      fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

      # Homebrew is installed by hand (docs/install.md)
      homebrew = {
        enable = true;
        # Uninstalls the casks and formulae not listed here. The upgrade skips those that update themselves
        onActivation = {
          autoUpdate = true;
          upgrade = true;
          cleanup = "uninstall";
        };
        casks =
          # For both accounts, in /Applications
          [
            "brave-browser"
            "firefox"
            "ghostty"
            "gimp"
            "libreoffice"
            "vlc"
            "zed"
          ]
          # For the main account only, in ~/Applications
          ++
            map
              (name: {
                inherit name;
                args.appdir = "~/Applications";
              })
              [
                "audacity"
                "element"
                "obsidian"
                "pearcleaner"
                "signal"
                "spotify"
                "steam"
                # Its own Syncthing, with the menu bar icon (the tray is Linux only)
                "syncthing-app"
              ];
      };

      users.users.fabien.home = "/Users/fabien";
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        users.fabien = {
          imports = with homeManager; [
            bash
            cli
            git
            ghostty
            ssh
            zed
          ];
          home.stateVersion = "26.05";
          programs.git.settings.user = {
            name = "Aenyhm";
            email = private.emails.aenyhm;
          };
          # GNU ls, for the colours
          home.packages = [ pkgs.coreutils ];
          programs.bash.shellAliases.ls = "ls --color=tty";
          programs.bash.initExtra = ''eval "$(dircolors -b)"'';
          # The apps come from Homebrew, Nix only writes their config
          programs.ghostty.package = null;
          # A macOS point is 1 px, a Linux one 4/3 px: 16 here matches Zed, like 12 on Linux
          programs.ghostty.settings.font-size = lib.mkForce 16;
          programs.ghostty.settings = {
            # Downloads updates and installs them at the next start, without asking
            auto-update = "download";
          };
          programs.zed-editor.package = null;
          # Zed updates itself, the Homebrew upgrade skips it
          programs.zed-editor.userSettings.auto_update = lib.mkForce true;
        };
      };
    };

  flake.darwinConfigurations.aenyhm-mac = inputs.nix-darwin.lib.darwinSystem {
    specialArgs = { inherit inputs; };
    modules = [ darwin.host-mac ];
  };
}
