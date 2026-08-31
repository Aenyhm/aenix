{
  flake.nixosModules.dualboot-windows = { ... }: {
    # Windows uses local time in RTC.
    time.hardwareClockInLocalTime = true;

    boot.loader.grub.useOSProber = true;
  };
}
