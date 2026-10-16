{
  flake.modules.homeManager.apps = {
    programs.firefox = {
      enable = true;
      languagePacks = [ "fr" ];

      # Installed at first start, then updated by Firefox
      policies.ExtensionSettings =
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
          };

      profiles.default.settings = {
        # Startup and interface
        "browser.startup.page" = 3; # restore the previous session
        "browser.shell.checkDefaultBrowser" = false;
        "browser.aboutConfig.showWarning" = false;
        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.theme.toolbar-theme" = 0; # dark
        "sidebar.visibility" = "hide-launcher";
        "browser.translations.neverTranslateLanguages" = "en";
        "layout.spellcheckDefault" = 0;
        "accessibility.force_disabled" = 1;

        # Downloads: ask where to save, and what to do with a new file type
        "browser.download.useDownloadDir" = false;
        "browser.download.always_ask_before_handling_new_types" = true;

        # New tab and address bar, without sponsored content or suggestions
        "browser.newtabpage.activity-stream.showSearch" = false;
        "browser.newtabpage.activity-stream.hideLogo" = true;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
        "browser.newtabpage.activity-stream.showWeather" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
        "browser.urlbar.suggest.quicksuggest.all" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;

        # Passwords and forms stay in Bitwarden
        "signon.rememberSignons" = false;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;

        # Privacy: strict tracking protection, DNS over HTTPS with fallback, no prefetching, no telemetry
        "browser.contentblocking.category" = "strict";
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.userContext.enabled" = false;
        "network.trr.mode" = 2;
        "network.trr.uri" = "https://mozilla.cloudflare-dns.com/dns-query";
        "network.dns.disablePrefetch" = true;
        "network.prefetch-next" = false;
        "network.http.speculative-parallel-limit" = 0;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.usage.uploadEnabled" = false;
        "media.eme.enabled" = true; # DRM, for streaming sites

        # Developer tools
        "devtools.theme" = "dark";
        "devtools.cache.disabled" = true;
      };
    };
  };
}
