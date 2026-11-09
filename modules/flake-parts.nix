{ inputs, ... }:
let
  # AeTheme, colours of text editor and terminal
  paletteDark = {
    bg = "#121110";
    line = "#1a1917"; # current line
    selection = "#36322d";
    highlight = "#5b5237"; # selected element, a dark yellow
    gutter = "#615d57"; # line numbers
    comment = "#9a9184";
    fg = "#e9ddc4";
    yellow = "#d5af57";
    green = "#a8c06e";
    blue = "#83c0cc";
    purple = "#d7a4b6";
    red = "#f67a6c";
    orange = "#f29e5b";
    cyan = "#8dc2aa";
  };
  paletteLight = {
    bg = "#f8f6f4";
    line = "#ece9e4";
    selection = "#d8d0c3";
    highlight = "#e1d3b3";
    gutter = "#97918a";
    comment = "#71675d";
    fg = "#2c251f";
    yellow = "#7d5e00";
    green = "#586d03";
    blue = "#226e7c";
    purple = "#855165";
    red = "#b6322b";
    orange = "#9f5000";
    cyan = "#347158";
  };
in
{
  # Declares flake.modules.<class>.<name>, one file can then hold the nixos and homeManager halves of a feature
  imports = [ inputs.flake-parts.flakeModules.modules ];

  # Monospace font of the desktop and Ghostty (Zed names it in apps/zed/settings.json), installed by the base module
  _module.args.monoFont = "JetBrainsMono Nerd Font Mono";

  _module.args.paletteDark = paletteDark;
  _module.args.paletteLight = paletteLight;
  _module.args.noHashPaletteDark = builtins.mapAttrs (_: builtins.substring 1 (-1)) paletteDark;

  # .desktop name of the default browser: links, the desktop, taskbar launchers
  _module.args.defaultBrowser = "brave-browser";

  # Emails and name of the work session on the login screen, kept in Aenyhm/aenix-private
  _module.args.private = import "${inputs.private}/private.nix";
}
