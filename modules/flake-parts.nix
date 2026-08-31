{ inputs, ... }:
{
  # Declares flake.modules.<class>.<name>, one file can then hold the nixos and homeManager halves of a feature
  imports = [ inputs.flake-parts.flakeModules.modules ];

  # Monospace font of KDE and Ghostty (Zed names it in apps/zed/settings.json), installed by the base module
  _module.args.monoFont = "JetBrainsMono Nerd Font Mono";

  # AeTheme colours of Zed and Ghostty, inspired by Gruvbox and Gruber Darker.
  # Accents share an OKLCH lightness near 0.76, with hues spread apart
  _module.args.palette = {
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

  # .desktop name of the default browser: links, KDE, taskbar launchers
  _module.args.defaultBrowser = "brave-browser";

  # Emails and name of the work session on the login screen, kept in Aenyhm/aenix-private
  _module.args.private = import "${inputs.private}/private.nix";
}
