{ defaultBrowser, ... }:
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

  flake.modules.homeManager.apps = { pkgs, ... }: {
    home.packages = with pkgs; [
      # Commands
      curl
      jq
      tree
      wget

      # Nix commands
      nixfmt
      nixfmt-tree # format a directory

      # LSP
      nixd # for Zed

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

    programs.htop.enable = true;

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
