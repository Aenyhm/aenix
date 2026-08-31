{
  flake.modules.nixos.base =
    {
      config,
      lib,
      pkgs,
      inputs,
      ...
    }:
    {
      # The users of the host, each with the home-manager modules of its profile
      options.aenix.users = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              fullName = lib.mkOption { type = lib.types.str; };
              email = lib.mkOption { type = lib.types.str; };
              homeModules = lib.mkOption { type = lib.types.listOf lib.types.deferredModule; };
              # .desktop names pinned in the taskbar, in this order
              launchers = lib.mkOption { type = lib.types.listOf lib.types.str; };
            };
          }
        );
      };

      config = {
        users.users = lib.mapAttrs (_: user: {
          isNormalUser = true;
          description = user.fullName;
          extraGroups = [
            "networkmanager"
            "wheel"
          ];
        }) config.aenix.users;

        time.timeZone = "Europe/Paris";
        i18n.defaultLocale = "fr_FR.UTF-8";
        services.xserver.xkb = {
          layout = "fr";
          variant = "oss";
        };
        console.keyMap = "fr";

        nixpkgs.config.allowUnfree = true;

        nixpkgs.overlays = [
          (final: _prev: {
            # Reuses the system nixpkgs config (allowUnfree, etc.)
            unstable = import inputs.nixpkgs-unstable {
              inherit (final.stdenv.hostPlatform) system;
              config = final.config;
            };
          })
        ];

        fonts.packages = with pkgs; [
          nerd-fonts.jetbrains-mono
          noto-fonts-color-emoji
        ];

        networking.networkmanager.enable = true;

        services.avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
        };
        services.printing.enable = true;

        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          pulse.enable = true;
        };

        hardware.bluetooth = {
          enable = true;
          settings.General.Experimental = true;
        };

        # One SSH agent per session, ~/.ssh keys are added at first use (modules/apps/ssh.nix)
        programs.ssh.startAgent = true;

        # Firmware and BIOS updates published by the vendor: fwupdmgr refresh && fwupdmgr update
        services.fwupd.enable = true;

        # Binaries built for other distributions (Pythons from uv, native wheels, vite-plus, Claude Code,
        # language servers downloaded by Zed, Playwright browsers) look for the loader and libraries
        # in fixed paths. nix-ld answers there, with the library set NixOS uses to run AppImages.
        programs.nix-ld = {
          enable = true;
          libraries = with pkgs.appimageTools.defaultFhsEnvArgs; targetPkgs pkgs ++ multiPkgs pkgs;
        };
        # Scripts starting with #!/bin/bash or calling /usr/bin/<tool> find the tool through the PATH
        services.envfs.enable = true;

        # Electron apps (Slack, Spotify, Obsidian) run natively on Wayland, sharp under fractional scaling
        environment.sessionVariables.NIXOS_OZONE_WL = "1";
      };
    };
}
