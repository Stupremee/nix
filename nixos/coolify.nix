{
  pkgs,
  lib,
  config,
  ...
}: {
  age.secrets.coolifyEnv.file = ../secrets/coolify.env;

  # hardcoded SSH key for coolify that was generated in advance
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINs7G9hlH/rNYo2aVx0VNwFMnY58GB3XuUSmHhBLwDeC root@coolify"
  ];

  # Containers
  virtualisation.oci-containers.containers."coolify" = {
    image = "ghcr.io/coollabsio/coolify:latest";

    environment = {
      "APP_ENV" = "production";
      "PHP_PM_CONTROL" = "dynamic";
      "PHP_PM_MAX_SPARE_SERVERS" = "10";
      "PHP_PM_MIN_SPARE_SERVERS" = "1";
      "PHP_PM_START_SERVERS" = "1";
      "SSL_MODE" = "off";
    };

    environmentFiles = [config.age.secrets.coolifyEnv.path];

    volumes = [
      "/var/lib/coolify/applications:/var/www/html/storage/app/applications:rw"
      "/var/lib/coolify/backups:/var/www/html/storage/app/backups:rw"
      "/var/lib/coolify/databases:/var/www/html/storage/app/databases:rw"
      "/var/lib/coolify/services:/var/www/html/storage/app/services:rw"
      "/var/lib/coolify/ssh:/var/www/html/storage/app/ssh:rw"
      "/var/lib/coolify/webhooks-during-maintenance:/var/www/html/storage/app/webhooks-during-maintenance:rw"
    ];

    ports = [
      "127.0.0.1:8000:80/tcp"
    ];

    dependsOn = [
      "coolify-db"
      "coolify-realtime"
      "coolify-redis"
    ];

    log-driver = "journald";

    extraOptions = [
      "--add-host=host.docker.internal:host-gateway"
      "--health-cmd=curl --fail http://127.0.0.1:80/api/health || exit 1"
      "--health-interval=5s"
      "--health-retries=10"
      "--health-timeout=2s"
      "--network-alias=coolify"
      "--network=coolify"
    ];
  };

  systemd.services."docker-coolify" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    partOf = [
      "docker-compose-coolify-root.target"
    ];
    wantedBy = [
      "docker-compose-coolify-root.target"
    ];
  };

  virtualisation.oci-containers.containers."coolify-db" = {
    image = "postgres:15-alpine";

    environment = {
      "POSTGRES_DB" = "coolify";
    };
    environmentFiles = [config.age.secrets.coolifyEnv.path];

    volumes = [
      "coolify-db:/var/lib/postgresql/data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=pg_isready -U "
      "--health-interval=5s"
      "--health-retries=10"
      "--health-timeout=2s"
      "--network-alias=postgres"
      "--network=coolify"
    ];
  };

  systemd.services."docker-coolify-db" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-volume-coolify-db.service"
    ];
    requires = [
      "docker-volume-coolify-db.service"
    ];
    partOf = [
      "docker-compose-coolify-root.target"
    ];
    wantedBy = [
      "docker-compose-coolify-root.target"
    ];
  };

  virtualisation.oci-containers.containers."coolify-realtime" = {
    image = "ghcr.io/coollabsio/coolify-realtime:1.0.2";

    environment = {
      "APP_NAME" = "Coolify";
      "SOKETI_DEBUG" = "false";
      "SOKETI_DEFAULT_APP_ID" = "";
      "SOKETI_DEFAULT_APP_KEY" = "";
      "SOKETI_DEFAULT_APP_SECRET" = "";
    };
    environmentFiles = [config.age.secrets.coolifyEnv.path];

    volumes = [
      "/var/lib/coolify/ssh:/var/www/html/storage/app/ssh:rw"
    ];

    ports = [
      "127.0.0.1:6001:6001/tcp"
      "127.0.0.1:6002:6002/tcp"
    ];

    log-driver = "journald";

    extraOptions = [
      "--add-host=host.docker.internal:host-gateway"
      "--health-cmd=wget -qO- http://127.0.0.1:6001/ready && wget -qO- http://127.0.0.1:6002/ready || exit 1"
      "--health-interval=5s"
      "--health-retries=10"
      "--health-timeout=2s"
      "--network-alias=soketi"
      "--network=coolify"
    ];
  };

  systemd.services."docker-coolify-realtime" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    partOf = [
      "docker-compose-coolify-root.target"
    ];
    wantedBy = [
      "docker-compose-coolify-root.target"
    ];
  };

  virtualisation.oci-containers.containers."coolify-redis" = {
    image = "docker.dragonflydb.io/dragonflydb/dragonfly";

    environmentFiles = [config.age.secrets.coolifyEnv.path];

    volumes = [
      "coolify-redis:/data:rw"
    ];

    log-driver = "journald";
    extraOptions = [
      "--ulimit"
      "memlock=1"
      "--health-cmd=redis-cli ping"
      "--health-interval=5s"
      "--health-retries=10"
      "--health-timeout=2s"
      "--network-alias=redis"
      "--network=coolify"
    ];
  };

  systemd.services."docker-coolify-redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-volume-coolify-redis.service"
    ];
    requires = [
      "docker-volume-coolify-redis.service"
    ];
    partOf = [
      "docker-compose-coolify-root.target"
    ];
    wantedBy = [
      "docker-compose-coolify-root.target"
    ];
  };

  # Volumes
  systemd.services."docker-volume-coolify-db" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect coolify-db || docker volume create coolify-db
    '';
    partOf = ["docker-compose-coolify-root.target"];
    wantedBy = ["docker-compose-coolify-root.target"];
  };

  systemd.services."docker-volume-coolify-redis" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect coolify-redis || docker volume create coolify-redis
    '';
    partOf = ["docker-compose-coolify-root.target"];
    wantedBy = ["docker-compose-coolify-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-coolify-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}
