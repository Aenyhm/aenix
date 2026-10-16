{ monoFont, palette, ... }:
{
  flake.modules.homeManager.apps = {
    programs.ghostty = {
      enable = true;

      themes.aetheme = with palette; {
        background = bg;
        foreground = fg;
        cursor-color = yellow;
        selection-background = selection;
        # ANSI 0-7, then their bright versions 8-15
        palette = [
          "0=${selection}"
          "1=${red}"
          "2=${green}"
          "3=${yellow}"
          "4=${blue}"
          "5=${purple}"
          "6=${cyan}"
          "7=${fg}"
          "8=${comment}"
          "9=${red}"
          "10=${green}"
          "11=${yellow}"
          "12=${blue}"
          "13=${purple}"
          "14=${cyan}"
          "15=${fg}"
        ];
      };

      settings = {
        window-width = 110;
        window-height = 55;
        font-size = 12;
        theme = "aetheme";
        font-family = monoFont;
        keybind = [
          "ctrl+t=new_tab"
        ];
      };
    };
  };
}
