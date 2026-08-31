{ pkgs, ... }:

{
  # TODO: settings
  programs.claude-code.enable = true;

  home.packages = with pkgs; [
    # TODO: wazuh, docker, opentofu, pgadmin4, etc.
    jetbrains.pycharm
    meld
    slack
  ];
}
