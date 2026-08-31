{
  fonts.fontconfig.enable = true;

  # Fix Obsidian opening in a separate Wayland window
  xdg.desktopEntries.obsidian = {
    name = "Obsidian";
    comment = "Knowledge base";
    exec = "obsidian %u";
    icon = "obsidian";
    terminal = false;
    type = "Application";
    categories = [ "Office" ];
    mimeType = [ "x-scheme-handler/obsidian" ];

    settings = {
      StartupWMClass = "md.obsidian.Obsidian";
    };
  };
}
