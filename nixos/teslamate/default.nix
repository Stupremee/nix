{
  pkgs,
  system,
  config,
  inputs,
  ...
}: let
  inherit (pkgs.lib) getExe;

  port = "33005";
  pkg =
    inputs.teslamate.packages.${system}.default;

  psql-init = pkgs.writeText "teslamate-psql-init" ''
    CREATE USER teslamate with encrypted password '@@DB_PASSWORD@@';
    GRANT ALL PRIVILEGES ON DATABASE teslamate TO teslamate;
    ALTER USER teslamate WITH SUPERUSER;
  '';
in {
  services.caddy.virtualHosts."tesla.stu-dev.me".extraConfig = ''
    handle_path /.well-known/appspecific/* {
      root * ${../../public/tesla}
      file_server
    }

    handle {
      basicauth {
        stu $2a$14$qXVRhoHBZH38GNhbNcmHsOg8eJeDzgFmDuMAj.7wNzNG7qCDvdoEq
      }
      reverse_proxy :${port}
    }
  '';

  age.secrets.teslamateEnv = {
    file = ../../secrets/teslamate.env;
    owner = "teslamate";
    group = "teslamate";
  };

  users.users.teslamate = {
    isSystemUser = true;
    group = "teslamate";
    home = "/var/lib/teslamate";
    createHome = true;
  };
  users.groups.teslamate = {};

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        address = "127.0.0.1";
        acl = ["pattern readwrite #"];
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
      }
    ];
  };

  services.postgresql.ensureDatabases = ["teslamate"];

  systemd.services."postgresql-teslamate-setup" = {
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
    };

    requiredBy = ["teslamate.service"];
    after = ["postgresql.service"];

    path = with pkgs; [postgresql_16 replace-secret];

    serviceConfig = {
      RuntimeDirectory = "postgresql-setup";
      RuntimeDirectoryMode = "700";
      EnvironmentFile = config.age.secrets.teslamateEnv.path;
    };

    script = ''
      # set bash options for early fail and error output
      set -o errexit -o pipefail -o nounset -o errtrace -o xtrace
      shopt -s inherit_errexit

      install --mode 600 ${psql-init} ''$RUNTIME_DIRECTORY/init.sql
      sed -i "s/@@DB_PASSWORD@@/$DATABASE_PASS/" ''$RUNTIME_DIRECTORY/init.sql

      # run filled SQL template
      psql teslamate --file "''$RUNTIME_DIRECTORY/init.sql"

      rm $RUNTIME_DIRECTORY/init.sql
    '';
  };

  systemd.services.teslamate = {
    description = "TeslaMate";
    after = ["network.target" "postgresql.service" "postgresql-teslamate-setup.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      User = "teslamate";
      Restart = "on-failure";
      RestartSec = 5;

      WorkingDirectory = "/var/lib/teslamate";

      ExecStartPre = ''${getExe pkg} eval "TeslaMate.Release.migrate"'';
      ExecStart = "${getExe pkg} start";
      ExecStop = "${getExe pkg} stop";

      EnvironmentFile = config.age.secrets.teslamateEnv.path;
    };

    environment = {
      PORT = port;
      DATABASE_USER = "teslamate";
      DATABASE_NAME = "teslamate";
      DATABASE_HOST = "127.0.0.1";
      DATABASE_PORT = "5432";
      VIRTUAL_HOST = "tesla.stu-dev.me";
      URL_PATH = "/";
      HTTP_BINDING_ADDRESS = "127.0.0.1";
      MQTT_HOST = "127.0.0.1";
      MQTT_PORT = "1883";
      CHECK_ORIGIN = "true";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [4488];
  };

  virtualisation.oci-containers.containers.fleet-telemetry = {
    image = "tesla/fleet-telemetry:v0.3.0";

    volumes = [
      "/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/tesla.stu-dev.me:/certs"
      "${./telemetry-config.json}:/etc/fleet-telemetry/config.json"
    ];

    extraOptions = ["--network=host"];
  };

  services.apache-kafka = {
    enable = true;
    settings = {
      "log.dirs" = ["/var/lib/kafka"];
      "zookeeper.connect" = "127.0.0.1:${builtins.toString config.services.zookeeper.port}";
    };
  };

  services.zookeeper = {
    enable = true;
  };
}
