{
  flake.modules.homeManager.apps =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      conf = "${config.xdg.configHome}/crow-translate/crow-translate.conf";
      crudini = "${pkgs.crudini}/bin/crudini --ini-options=nospace --set ${conf}";
    in
    {
      home.packages = [ pkgs.crow-translate ];

      # Crow Translate waits in the tray from login, for its global translate shortcuts
      xdg.autostart = {
        enable = true;
        entries = [ "${pkgs.crow-translate}/share/applications/org.kde.CrowTranslate.desktop" ];
      };

      # Only these keys are written, Crow keeps saving the others in the same file. The translation
      # instance stays out of it, see docs/how-to.md.
      # Speech through Mozhi (TTS backend 1): the default, Piper, asks at each start for voice models
      home.activation.crowTranslate = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p ${dirOf conf}
        run ${crudini} General StartMinimized true
        run ${crudini} TTS Backend 1
      '';
    };
}
