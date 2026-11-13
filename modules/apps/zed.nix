{
  config,
  paletteDark,
  paletteLight,
  ...
}:
let
  theme =
    name: appearance: p: with p; {
      inherit name appearance;
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
        "ghost_element.selected" = highlight;
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
    };
in
{
  flake.modules.homeManager.apps.imports = [ config.flake.modules.homeManager.zed ];

  flake.modules.homeManager.zed = {
    programs.zed-editor = {
      enable = true;
      themes.aetheme = {
        "$schema" = "https://zed.dev/schema/themes/v0.1.0.json";
        name = "AeTheme";
        author = "Aenyhm";
        themes = [
          (theme "AeTheme Dark" "dark" paletteDark)
          (theme "AeTheme Light" "light" paletteLight)
        ];
      };
      extensions = [
        "git-firefly"
        "html"
        "make"
        "nix"
        "sql"
        "terraform"
        "toml"
        "vue"
      ];
      # Zed also edits settings.json: each rebuild merges these keys into it
      userSettings = builtins.fromJSON (builtins.readFile ./zed/settings.json);
      userKeymaps = builtins.fromJSON (builtins.readFile ./zed/keymap.json);
    };
  };
}
