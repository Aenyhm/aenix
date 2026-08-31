{
  flake.nixosModules.zswap = { ... }: {
    boot.zswap = {
      enable = true;

      # Compressed swap cache uses at most 25% of RAM.
      maxPoolPercent = 25;

      # Zstd gives good compression and is the NixOS default.
      compressor = "zstd";

      # Reclaim compressed pages when memory pressure increases.
      shrinkerEnabled = true;

      # Start accepting pages again below 90% pool usage.
      acceptThresholdPercent = 90;
    };
  };
}
