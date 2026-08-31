{
  flake.modules.homeManager.apps =
    { pkgs, ... }:
    {
      programs.firefox = {
        enable = true;
        languagePacks = [ "fr" ];
        nativeMessagingHosts = [ pkgs.kdePackages.plasma-browser-integration ];

        # Policies first: one documented switch instead of the prefs behind it. Prefs for the rest
        policies = {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          SkipTermsOfUse = true;
          DontCheckDefaultBrowser = true;
          NoDefaultBookmarks = true;
          DisplayBookmarksToolbar = "never";

          # Passwords and forms stay in Bitwarden
          PasswordManagerEnabled = false;
          OfferToSaveLogins = false;
          AutofillAddressEnabled = false;
          AutofillCreditCardEnabled = false;

          EnableTrackingProtection = {
            Value = true;
            Category = "strict";
            Cryptomining = true;
            Fingerprinting = true;
            EmailTracking = true;
          };
          DNSOverHTTPS = {
            Enabled = true;
            ProviderURL = "https://mozilla.cloudflare-dns.com/dns-query";
            Fallback = true;
          };
          NetworkPrediction = false;

          # New tab, address bar and prompts without sponsored content or suggestions
          FirefoxHome = {
            Search = false;
            SponsoredTopSites = false;
            Stories = false;
            SponsoredStories = false;
            Snippets = false;
          };
          FirefoxSuggest = {
            WebSuggestions = false;
            SponsoredSuggestions = false;
            ImproveSuggest = false;
          };
          UserMessaging = {
            ExtensionRecommendations = false;
            FeatureRecommendations = false;
            UrlbarInterventions = false;
            SkipOnboarding = true;
            MoreFromMozilla = false;
            FirefoxLabs = false;
          };

          # Installed at first start, then updated by Firefox
          ExtensionSettings =
            builtins.mapAttrs
              (_: slug: {
                installation_mode = "normal_installed";
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
              })
              {
                "uBlock0@raymondhill.net" = "ublock-origin";
                "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
                "jid1-KKzOGWgsW3Ao4Q@jetpack" = "i-dont-care-about-cookies";
                "myallychou@gmail.com" = "youtube-recommended-videos";
                "{9a3104a2-02c2-464c-b069-82344e5ed4ec}" = "youtube-no-translation";
                "plasma-browser-integration@kde.org" = "plasma-integration";
              };
        };

        profiles.default.settings = {
          # Startup and interface
          "browser.startup.page" = 3; # restore the previous session
          "browser.aboutConfig.showWarning" = false;
          "browser.theme.toolbar-theme" = 0; # dark
          "sidebar.visibility" = "hide-launcher";
          "browser.translations.neverTranslateLanguages" = "en";
          "layout.spellcheckDefault" = 0;
          "accessibility.force_disabled" = 1;
          "browser.newtabpage.activity-stream.hideLogo" = true;
          "browser.newtabpage.activity-stream.showWeather" = false;

          # Downloads: ask where to save, and what to do with a new file type
          "browser.download.useDownloadDir" = false;
          "browser.download.always_ask_before_handling_new_types" = true;

          # Privacy without a policy: Global Privacy Control, no containers, no speculative connections
          "privacy.globalprivacycontrol.enabled" = true;
          "privacy.userContext.enabled" = false;
          "network.http.speculative-parallel-limit" = 0;
          "media.eme.enabled" = true; # DRM, for streaming sites

          # Developer tools
          "devtools.theme" = "dark";
          "devtools.cache.disabled" = true;
        };
      };
    };
}
