{
  flake.modules.nixos.base = {
    programs.chromium = {
      enable = true;
      extraOpts = {
        MetricsReportingEnabled = false;
        BraveP3AEnabled = false;
        BraveStatsPingEnabled = false;
        BraveWebDiscoveryEnabled = false;
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
        # Locked: the settings can no longer change it
        DefaultSearchProviderEnabled = true;
        DefaultSearchProviderName = "DuckDuckGo";
        DefaultSearchProviderKeyword = "duckduckgo.com";
        DefaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
        DefaultSearchProviderSuggestURL = "https://duckduckgo.com/ac/?q={searchTerms}&type=list";
      };
    };
  };

  flake.modules.homeManager.apps = {
    programs.brave = {
      enable = true;
      extensions = [
        { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
        { id = "khncfooichmfjbepaaaebmommgaepoid"; } # Unhook, no YouTube recommendations
        { id = "ndpmhjnlfkgfalaieeneneenijondgag"; } # YouTube Anti Translate
      ];
    };
  };
}
