{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Communication
    signal-desktop
    element-desktop
    mumble
  ];
}
