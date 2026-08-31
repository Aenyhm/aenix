{
  # Music of the Synology NAS, mounted at first access and shared by the users group: every user
  # finds it in ~/Musique/aenas2. The DSM account is in /etc/nas-credentials, out of the repository
  flake.modules.nixos.nas-music = {
    fileSystems."/mnt/aenas2" = {
      device = "//192.168.1.34/music";
      fsType = "cifs";
      options = [
        "credentials=/etc/nas-credentials"
        "gid=users"
        "file_mode=0664"
        "dir_mode=0775"
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
        "x-systemd.mount-timeout=5s"
        "nofail"
      ];
    };
    home-manager.sharedModules = [
      (
        { config, ... }:
        {
          home.file."Musique/aenas2".source = config.lib.file.mkOutOfStoreSymlink "/mnt/aenas2";
        }
      )
    ];
  };
}
