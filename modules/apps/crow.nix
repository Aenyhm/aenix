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

      # For its global shortcuts
      xdg.autostart = {
        enable = true;
        entries = [ "${pkgs.crow-translate}/share/applications/org.kde.CrowTranslate.desktop" ];
      };

      # Writes only these keys, Crow saves the rest in the same file. TTS 1 is Mozhi: Piper, the default,
      # asks for voice models at each start
      home.activation.crowTranslate = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p ${dirOf conf}
        run ${crudini} General StartMinimized true
        run ${crudini} TTS Backend 1
      '';
    };
}
