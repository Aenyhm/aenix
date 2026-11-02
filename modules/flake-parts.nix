{ inputs, ... }:
let
  # AeTheme colours of text editor and terminal, inspired by Gruvbox and Gruber Darker.
  # Accents share an OKLCH lightness near 0.76, with hues spread apart
  palette = {
    bg = "#121110";
    line = "#1a1917"; # current line
    selection = "#36322d";
    gutter = "#615d57"; # line numbers
    comment = "#928373";
    fg = "#f0e3ba";
    yellow = "#deb459";
    green = "#a5bc6b";
    blue = "#78b7be";
    purple = "#d3a0b3";
    red = "#ed756e";
    orange = "#e99355";
    cyan = "#7fc2a4";
  };
in
{
  # Declares flake.modules.<class>.<name>, one file can then hold the nixos and homeManager halves of a feature
  imports = [ inputs.flake-parts.flakeModules.modules ];

  # Monospace font of the desktop and Ghostty (Zed names it in apps/zed/settings.json), installed by the base module
  _module.args.monoFont = "JetBrainsMono Nerd Font Mono";

  _module.args.palette = palette;
  _module.args.noHashPalette = builtins.mapAttrs (_: builtins.substring 1 (-1)) palette;

  # .desktop name of the default browser: links, the desktop, taskbar launchers
  _module.args.defaultBrowser = "brave-browser";

  # Emails and name of the work session on the login screen, kept in Aenyhm/aenix-private
  _module.args.private = import "${inputs.private}/private.nix";
}
