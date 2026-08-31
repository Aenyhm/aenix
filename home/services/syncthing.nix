{ pkgs, ... }:
{
  # If not working: configure using the GUI then:
  #   rm ~/.config/syncthingtray.ini
  #   systemctl --user restart syncthingtray
  services.syncthing.tray = {
    enable = true;

    # Use the full Qt tray application while configuring it.
    package = pkgs.syncthingtray;

    command = "syncthingtray --wait";
  };
}
