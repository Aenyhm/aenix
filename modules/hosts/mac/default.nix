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
  # The personal Mac under nix-darwin. Shared with a second account that Nix leaves
  # alone: it only gets the shared apps, installed by Homebrew in /Applications
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
      # Never change it, as system.stateVersion on NixOS
      system.stateVersion = 7;
      # The user that Homebrew and the per-user macOS settings belong to
      system.primaryUser = "fabien";

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      environment.systemPackages = [
        pkgs.bashInteractive
        pkgs.nh
      ];
      # brew, after the Nix tools so a package of both runs the Nix one
      environment.systemPath = lib.mkAfter [ "${config.homebrew.prefix}/bin" ];
      # Allowed as login shell, set once with chsh (docs/install.md)
      environment.shells = [ pkgs.bashInteractive ];
      # Where nh finds the flake, as on Linux (apps/update.nix)
      environment.variables.NH_FLAKE = "/Users/fabien/aenix";
      fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

      # Signed apps that update themselves. Homebrew is installed by hand (docs/install.md)
      homebrew = {
        enable = true;
        # Uninstalls the casks not listed here. The upgrade skips those that update themselves
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
                "signal"
                "spotify"
                "steam"
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
            syncthing
            zed
          ];
          home.stateVersion = "26.05";
          programs.git.settings.user = {
            name = "Aenyhm";
            email = private.emails.aenyhm;
          };
          # GNU ls, coloured as on Linux, where NixOS sets the alias and the colours
          home.packages = [ pkgs.coreutils ];
          programs.bash.shellAliases.ls = "ls --color=tty";
          programs.bash.initExtra = ''eval "$(dircolors -b)"'';
          # The apps come from Homebrew, Nix only writes their config
          programs.ghostty.package = null;
          # macOS counts a point as one pixel where Linux counts 4/3: 16 matches Zed, as 12 does on Linux
          programs.ghostty.settings.font-size = lib.mkForce 16;
          programs.ghostty.settings = {
            # Downloads the updates and installs them at the next start, without asking first
            auto-update = "download";
          };
          # The tray runs as a systemd service, Linux only: the GUI stays at 127.0.0.1:8384
          services.syncthing.tray.enable = lib.mkForce false;
          programs.zed-editor.package = null;
          # Homebrew leaves the Zed upgrades to Zed itself
          programs.zed-editor.userSettings.auto_update = lib.mkForce true;
        };
      };
    };

  flake.darwinConfigurations.aenyhm-mac = inputs.nix-darwin.lib.darwinSystem {
    specialArgs = { inherit inputs; };
    modules = [ darwin.host-mac ];
  };
}
