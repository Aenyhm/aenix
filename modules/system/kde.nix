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
  # Plasma on Wayland with the SDDM login screen, the KDE apps, and what KDE adds to the other
  # apps (browsers, file manager in the launchers): dropping this import drops KDE
  flake.modules.nixos.kde = { pkgs, ... }: {
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

    environment.systemPackages = with pkgs.kdePackages; [
      arianna
      kamoso
      kcalc
      kcolorchooser
      kompare # diff viewer
      partitionmanager
      sddm-kcm # the login screen page of the settings, see docs/how-to.md
      skanlite
    ];
    # Added to the default applications of apps/common.nix
    xdg.mime.defaultApplications = {
      "inode/directory" = "org.kde.dolphin.desktop";
      "application/pdf" = "org.kde.okular.desktop";
      "image/png" = "org.kde.gwenview.desktop";
      "image/jpeg" = "org.kde.gwenview.desktop";
    };
    home-manager.sharedModules = [ hm.kde ];
  };

  # Only the keys below are written, anything else stays editable from the KDE settings
  flake.modules.homeManager.kde =
    {
      config,
      inputs,
      lib,
      osConfig,
      pkgs,
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
      # Dolphin goes right after the terminal, the first launcher of every user
      launchers = osConfig.aenix.users.${config.home.username}.launchers;
    in
    {
      imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

      # Plasma Integration: media controls and downloads of the browsers in the Plasma tray
      programs.firefox = {
        nativeMessagingHosts = [ pkgs.kdePackages.plasma-browser-integration ];
        policies.ExtensionSettings."plasma-browser-integration@kde.org" = {
          installation_mode = "normal_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/plasma-integration/latest.xpi";
          private_browsing = true;
        };
      };
      programs.brave.extensions = [ { id = "cimiefiiaegbelhefglklhhakcgmhkai"; } ];

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
                  launchers = map (app: "applications:${app}.desktop") (
                    lib.take 1 launchers ++ [ "org.kde.dolphin" ] ++ lib.drop 1 launchers
                  );
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
