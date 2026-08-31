{
  # Policies apply to every Brave on the host (/etc/brave/policies), the extensions to each user
  flake.modules.nixos.base = {
    programs.chromium = {
      enable = true;
      extraOpts = {
        # Telemetry
        MetricsReportingEnabled = false;
        BraveP3AEnabled = false;
        BraveStatsPingEnabled = false;
        BraveWebDiscoveryEnabled = false;
        # Brave products not used
        BraveRewardsDisabled = true;
        BraveWalletDisabled = true;
        BraveVPNDisabled = true;
        BraveAIChatEnabled = false;
        BraveLocalAIEnabled = false;
        BraveNewsDisabled = true;
        BraveTalkDisabled = true;
        BravePlaylistEnabled = false;
        # Passwords and forms stay in Bitwarden
        PasswordManagerEnabled = false;
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        DefaultBrowserSettingEnabled = false;
      };
    };
  };

  flake.modules.homeManager.apps =
    { pkgs, ... }:
    {
      programs.brave = {
        enable = true;
        package = pkgs.brave; # TODO: brave-origin once nixpkgs has it, then check defaultBrowser (its .desktop name)
        # Installed at first start from the Chrome Web Store, then updated by Brave
        extensions = [
          { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
          { id = "cimiefiiaegbelhefglklhhakcgmhkai"; } # Plasma Integration
          { id = "khncfooichmfjbepaaaebmommgaepoid"; } # Unhook, no YouTube recommendations
          { id = "ndpmhjnlfkgfalaieeneneenijondgag"; } # YouTube Anti Translate
        ];
      };
    };
}
