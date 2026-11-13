{ config, defaultBrowser, ... }:
{
  # ~/.config/mimeapps.list overrides these, and stays writable for apps that register links
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

  flake.modules.homeManager.cli = { pkgs, ... }: {
    home.packages = with pkgs; [
      curl
      ffmpeg
      jq
      tree
      wget
      zip
      unzip

      nixfmt
      nixfmt-tree # provides treefmt
      nixd # LSP for Zed
    ];

    programs.htop.enable = true;
  };

  flake.modules.homeManager.apps = { pkgs, ... }: {
    imports = [ config.flake.modules.homeManager.cli ];

    home.packages = with pkgs; [
      gimp
      libreoffice-qt-fresh
      obsidian
      rhythmbox
      spotify
      vlc
      wl-clipboard
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
