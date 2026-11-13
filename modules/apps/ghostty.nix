{
  config,
  monoFont,
  paletteDark,
  paletteLight,
  ...
}:
let
  # ANSI black is the theme's dark end and white its light end, whatever the background
  theme =
    p: black: white: with p; {
      background = bg;
      foreground = fg;
      cursor-color = yellow;
      selection-background = selection;
      # ANSI 0-7, then their bright versions 8-15
      palette = [
        "0=${black}"
        "1=${red}"
        "2=${green}"
        "3=${yellow}"
        "4=${blue}"
        "5=${purple}"
        "6=${cyan}"
        "7=${white}"
        "8=${comment}"
        "9=${red}"
        "10=${green}"
        "11=${yellow}"
        "12=${blue}"
        "13=${purple}"
        "14=${cyan}"
        "15=${white}"
      ];
    };
in
{
  flake.modules.homeManager.apps.imports = [ config.flake.modules.homeManager.ghostty ];

  flake.modules.homeManager.ghostty = {
    programs.ghostty = {
      enable = true;

      themes = {
        aetheme-dark = theme paletteDark paletteDark.selection paletteDark.fg;
        aetheme-light = theme paletteLight paletteLight.fg paletteLight.selection;
      };

      settings = {
        window-width = 110;
        window-height = 55;
        font-size = 12;
        theme = "light:aetheme-light,dark:aetheme-dark";
        font-family = monoFont;
        keybind = [
          "ctrl+t=new_tab"
        ];
      };
    };
  };
}
