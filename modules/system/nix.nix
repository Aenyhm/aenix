{
  flake.modules.nixos.nix = {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    # Replaces identical files in the store with hard links
    nix.optimise.automatic = true;

    # nh wraps nixos-rebuild and lists the package changes before switching. Its cleaner also
    # removes old home-manager generations, which nix.gc keeps
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep-since 15d --keep 10";
      };
    };
  };
}
