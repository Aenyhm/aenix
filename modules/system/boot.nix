{
  flake.modules.nixos.boot = { pkgs, ... }: {
    # boot.kernelPackages = pkgs.linuxPackages_latest; # LTS by default
    boot.loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
        configurationLimit = 10; # each generation copies its kernel to the small EFI partition
      };
    };
    boot.zswap.enable = true;

    # The swap is smaller than the RAM, so hibernation would fail: KDE stops offering it
    systemd.sleep.settings.Sleep = {
      AllowHibernation = false;
      AllowHybridSleep = false;
      AllowSuspendThenHibernate = false;
    };
  };
}
