{
  config,
  defaultBrowser,
  monoFont,
  ...
}:
let
  hm = config.flake.modules.homeManager;
in
{
  # Plasma on Wayland with the SDDM login screen, and the KDE apps: dropping this import drops KDE
  flake.modules.nixos.desktop = { pkgs, ... }: {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      settings.General.RememberLastSession = true;
    };

    services.desktopManager.plasma6.enable = true;
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      discover
      elisa
      kate
      konsole
      qrca
    ];

    environment.systemPackages = with pkgs; [
      crow-translate
      kdePackages.arianna
      kdePackages.kamoso
      kdePackages.kcalc
      kdePackages.kcolorchooser
      kdePackages.kompare # diff viewer
      kdePackages.partitionmanager
      kdePackages.sddm-kcm # the login screen page of the settings, see docs/how-to.md
      kdePackages.skanlite
    ];
    home-manager.sharedModules = [ hm.desktop ];
  };

  # Only the keys below are written, anything else stays editable from the KDE settings
  flake.modules.homeManager.desktop =
    {
      config,
      inputs,
      osConfig,
      ...
    }:
    let
      # Pie chart refreshed every 3 seconds, the default 0.5s is too busy. No sensor colour, Plasma picks one
      monitor = title: sensor: {
        systemMonitor = {
          inherit title;
          displayStyle = "org.kde.ksysguard.piechart";
          totalSensors = [ sensor ];
          settings.Sensors.highPrioritySensorIds = ''["${sensor}"]'';
          settings.Appearance.updateRateLimit = 3000;
        };
      };
      # Where KDE keeps the wallpaper, and where it is saved across a panel rebuild
      applets = "${config.xdg.configHome}/plasma-org.kde.plasma.desktop-appletsrc";
      saved = "${config.xdg.dataHome}/plasma-manager/wallpaper";
    in
    {
      imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

      programs.plasma = {
        enable = true;
        # A changed panel makes plasma-manager delete the file holding the wallpaper (priority 2).
        # The wallpaper chosen in KDE is saved before at each login, and set again after if lost
        startup.startupScript.wallpaper_save = {
          priority = 1;
          runAlways = true;
          text = ''
            image=$(grep -m1 '^Image=' ${applets} 2>/dev/null | cut -d= -f2- | sed 's|^file://||')
            if [ -n "$image" ]; then echo "$image" > ${saved}; fi
          '';
        };
        startup.startupScript.wallpaper_restore = {
          priority = 4;
          runAlways = true;
          text = ''
            image=$(cat ${saved} 2>/dev/null)
            if [ -n "$image" ] && ! grep -qF "$image" ${applets} 2>/dev/null; then
              plasma-apply-wallpaperimage "$image"
            fi
          '';
        };
        input.keyboard.numlockOnStartup = "on";
        workspace = {
          colorScheme = "BreezeDark";
          theme = "breeze-dark";
        };
        fonts.fixedWidth = {
          family = monoFont;
          pointSize = 10;
        };

        kwin.virtualDesktops.number = 1;

        # Only the AC section applies to a desktop without battery
        powerdevil = {
          AC.powerProfile = "performance";
          battery.powerProfile = "powerSaving";
          lowBattery.powerProfile = "powerSaving";
        };
        # 15 minutes is the most a company security policy tolerates
        kscreenlocker = {
          timeout = 15;
          passwordRequiredDelay = 60;
        };

        panels = [
          {
            location = "right";
            height = 44; # 44 by default
            floating = false;
            widgets = [
              "org.kde.plasma.kickoff"
              {
                iconTasks = {
                  launchers = map (
                    app: "applications:${app}.desktop"
                  ) osConfig.aenix.users.${config.home.username}.launchers;
                  appearance.iconSpacing = "small";
                };
              }
              (monitor "CPU" "cpu/all/usage")
              (monitor "RAM" "memory/physical/usedPercent")
              (monitor "Swap" "memory/swap/usedPercent")
              "org.kde.plasma.systemtray"
              {
                digitalClock.date = {
                  format.custom = "ddd d/M";
                  position = "belowTime";
                };
              }
              "org.kde.plasma.showdesktop"
            ];
          }
        ];

        configFile = {
          kdeglobals.KDE.AnimationDurationFactor = 0; # instant animations
          kdeglobals.General = {
            BrowserApplication = "${defaultBrowser}.desktop";
            TerminalApplication = "ghostty";
            TerminalService = "com.mitchellh.ghostty.desktop";
          };
          kdeglobals."KFileDialog Settings" = {
            "Allow Expansion" = false;
            "Show hidden files" = true;
          };
          kwinrc.NightColor.Active = true;
          kwinrc.Plugins.shakecursorEnabled = false;
          kservicemenurc.Show.hidefileitemaction = false;
          dolphinrc = {
            DetailsMode.ExpandableFolders = false;
            DetailsMode.PreviewSize = 32;
            General.OpenExternallyCalledFolderInNewTab = true;
            General.ShowFullPathInTitlebar = true;
            MainWindow.MenuBar = "Disabled";
            "Notification Messages".ConfirmRenameFileType = false;
          };
        };
      };
    };
}
