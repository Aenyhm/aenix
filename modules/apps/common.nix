{ config, defaultBrowser, ... }:
{
  # Default applications in /etc/xdg/mimeapps.list, the desktop module adds those of its own apps.
  # ~/.config/mimeapps.list stays free for the desktop settings and the apps registering their
  # links (Slack, Claude), and its entries win over these ones
  flake.modules.nixos.base.xdg.mime.defaultApplications = {
    "text/plain" = "dev.zed.Zed.desktop";
    "text/markdown" = "dev.zed.Zed.desktop";
    "text/html" = "${defaultBrowser}.desktop";
    "x-scheme-handler/http" = "${defaultBrowser}.desktop";
    "x-scheme-handler/https" = "${defaultBrowser}.desktop";
    "audio/mpeg" = "org.gnome.Rhythmbox3.desktop";
    "audio/flac" = "org.gnome.Rhythmbox3.desktop";
    "video/mp4" = "vlc.desktop";
    "video/x-matroska" = "vlc.desktop";
  };

  # Terminal commands, on the Mac too
  flake.modules.homeManager.cli = { pkgs, ... }: {
    home.packages = with pkgs; [
      curl
      jq
      tree
      wget
      zip
      unzip

      # Nix
      nixfmt
      nixfmt-tree # treefmt, formats a directory
      nixd # LSP for Zed
    ];

    programs.htop.enable = true;
  };

  flake.modules.homeManager.apps = { pkgs, ... }: {
    imports = [ config.flake.modules.homeManager.cli ];

    home.packages = with pkgs; [
      # Office
      libreoffice-qt-fresh # without Qt: libreoffice-fresh
      obsidian

      # Multimedia
      gimp
      rhythmbox
      spotify
      vlc

      # Development
      wl-clipboard # copy and paste from the terminal
    ];

    # Fix Obsidian opening in a separate Wayland window
    xdg.desktopEntries.obsidian = {
      name = "Obsidian";
      comment = "Knowledge base";
      exec = "obsidian %u";
      icon = "obsidian";
      categories = [ "Office" ];
      mimeType = [ "x-scheme-handler/obsidian" ];
      settings.StartupWMClass = "md.obsidian.Obsidian";
    };
  };
}
