{ private, ... }:
{
  # Repackages the official .deb: the company manager runs 4.9.2 and rejects any newer agent
  flake.modules.nixos.wazuh =
    { pkgs, ... }:
    let
      version = "4.9.2";
      manager = private.wazuhManager;

      package = pkgs.stdenv.mkDerivation {
        pname = "wazuh-agent";
        inherit version;
        src = pkgs.fetchurl {
          url = "https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_${version}-1_amd64.deb";
          hash = "sha256-9X2MoKGakLYj3pNfiqsYQ0s357lStJ6MQnFOAWxhYPI=";
        };
        nativeBuildInputs = [
          pkgs.dpkg
          pkgs.autoPatchelfHook
        ];
        unpackPhase = "dpkg-deb -x $src .";
        # Same steps as the .deb postinst: generic SCA policy and generated default config
        installPhase = ''
          cp -r var/ossec $out
          scripts=$out/packages_files/agent_installation_scripts
          rm $out/ruleset/sca/*
          cp $scripts/sca/generic/sca_unix_audit.yml $out/ruleset/sca/
          (cd $scripts && bash gen_ossec.sh conf agent nixos 26.05 /var/ossec) > $out/ossec.conf.template
        '';
        preFixup = "addAutoPatchelfSearchPath $out/lib";
      };

      ossecConf = pkgs.runCommand "ossec.conf" { } ''
        sed -e 's|MANAGER_IP|${manager}|' \
            -e 's|</server>|</server>\n    <enrollment>\n      <enabled>yes</enabled>\n      <groups>default</groups>\n    </enrollment>|' \
            ${package}/ossec.conf.template > $out
      '';

      # The binaries hardcode /var/ossec, so the package is copied there. Binaries follow the
      # package, state (agent key, logs, queues, config pushed by the manager) survives upgrades.
      deploy = pkgs.writeShellScript "wazuh-deploy" ''
        set -eu
        dir=/var/ossec
        if [ "$(cat $dir/.package 2>/dev/null)" != ${package} ]; then
          mkdir -p $dir
          cp -rf ${package}/{bin,lib,active-response,agentless,wodles} $dir/
          cp -r --update=none ${package}/. $dir/
          echo ${package} > $dir/.package
        fi
        install -m 660 -o root -g wazuh ${ossecConf} $dir/etc/ossec.conf
        install -m 640 -o root -g wazuh /etc/localtime $dir/etc/localtime
        sh ${package}/packages_files/agent_installation_scripts/restore-permissions.sh
      '';
    in
    {
      users.groups.wazuh = { };
      users.users.wazuh = {
        isSystemUser = true;
        group = "wazuh";
        home = "/var/ossec";
      };

      systemd.services.wazuh-agent = {
        description = "Wazuh agent";
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        # wazuh-control needs the first ones, the default config runs df, netstat and last
        path = with pkgs; [
          coreutils
          gawk
          gnused
          gnugrep
          procps
          nettools
          util-linux
        ];
        serviceConfig = {
          Type = "forking";
          ExecStartPre = deploy;
          ExecStart = "/var/ossec/bin/wazuh-control start";
          ExecStop = "/var/ossec/bin/wazuh-control stop";
          ExecReload = "/var/ossec/bin/wazuh-control reload";
          KillMode = "process";
          RemainAfterExit = true;
        };
      };
    };
}
