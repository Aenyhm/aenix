{ pkgs, ... }:

{
  # TODO: settings for each
  programs.firefox.enable = true;
  programs.git.enable = true;
  programs.zed-editor.enable = true;

  home.packages = with pkgs; [
    # Commands
    curl
    wget
    tree
    jq

    # Utilities
    kdePackages.konsole
    kdePackages.kcalc

    # Office
    kdePackages.skanlite
    obsidian
    libreoffice-qt-fresh

    # Multimedia
    kdePackages.kcolorchooser
    gimp
    rhythmbox
    vlc
    spotify
  ];
}
