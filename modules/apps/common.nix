{ defaultBrowser, ... }:
{
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

    # Default applications, KDE can no longer change them from its settings
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "org.kde.dolphin.desktop";
        "text/plain" = "dev.zed.Zed.desktop";
        "text/markdown" = "dev.zed.Zed.desktop";
        "text/html" = "${defaultBrowser}.desktop";
        "x-scheme-handler/http" = "${defaultBrowser}.desktop";
        "x-scheme-handler/https" = "${defaultBrowser}.desktop";
        "application/pdf" = "org.kde.okular.desktop";
        "image/png" = "org.kde.gwenview.desktop";
        "image/jpeg" = "org.kde.gwenview.desktop";
        "audio/mpeg" = "org.gnome.Rhythmbox3.desktop";
        "audio/flac" = "org.gnome.Rhythmbox3.desktop";
        "video/mp4" = "vlc.desktop";
        "video/x-matroska" = "vlc.desktop";
      };
    };

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
