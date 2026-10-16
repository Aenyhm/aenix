{ palette, ... }:
{
  flake.modules.homeManager.apps = {
    programs.zed-editor = {
      enable = true;
      themes.aetheme = with palette; {
        "$schema" = "https://zed.dev/schema/themes/v0.1.0.json";
        name = "AeTheme";
        author = "Aenyhm";
        themes = [
          {
            name = "AeTheme Dark";
            appearance = "dark";
            style = {
              "editor.background" = bg;
              "editor.foreground" = fg;
              "editor.line_number" = gutter;
              "editor.active_line_number" = yellow;
              "editor.active_line.background" = line;
              "editor.document_highlight.read_background" = selection;

              warning = orange;
              "warning.border" = orange;
              "warning.background" = line;
              error = red;
              "error.border" = red;
              "error.background" = line;
              "scrollbar_thumb.background" = "${selection}aa";
              "ghost_element.selected" = "#5b5237"; # a dark yellow
              "ghost_element.hover" = selection;

              "terminal.background" = bg;
              "terminal.foreground" = fg;
              "terminal.ansi.red" = red;
              "terminal.ansi.green" = green;
              "terminal.ansi.yellow" = yellow;
              "terminal.ansi.blue" = blue;
              "terminal.ansi.magenta" = purple;
              "terminal.ansi.cyan" = cyan;

              players = [
                {
                  cursor = yellow;
                  selection = selection;
                }
              ];
              syntax = {
                constant.color = purple;
                comment = {
                  color = comment;
                  font_style = "italic";
                };
                keyword.color = yellow;
                string.color = green;
                type.color = blue;
              };
            };
          }
        ];
      };
      # Plain Zed files, so a change made in Zed can be copied back as is.
      # Zed may still edit its settings.json, these keys are merged into it on each rebuild
      userSettings = builtins.fromJSON (builtins.readFile ./zed/settings.json);
      userKeymaps = builtins.fromJSON (builtins.readFile ./zed/keymap.json);
    };
  };
}
