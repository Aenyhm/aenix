{
  flake.modules.homeManager.apps =
    { pkgs, ... }:
    {
      # Default flake of nh, so `nh os switch` works from any directory
      home.sessionVariables.NH_FLAKE = "$HOME/aenix";

      home.packages = [
        (pkgs.writeShellApplication {
          name = "update";
          text = ''
            nh os switch --update
            fwupdmgr refresh --force
            # get-updates fails when there is nothing to install
            if fwupdmgr get-updates; then fwupdmgr update; fi
          '';
        })
      ];
    };
}
