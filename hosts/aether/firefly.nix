{ config, pkgs, ... }: {
  age.secrets.fireflyEnv.file = ../../secrets/firefly.env;

  virtualisation.oci-containers.containers.firefly = {
    image = "fireflyiii/core:version-5.6.2";
    environmentFiles = [ config.age.secrets.fireflyEnv.path ];
    extraOptions = [ "--network" "host" ];
  };

  age.secrets.initDatabase = {
    file = ../../secrets/initDatabase.sql;
    owner = "postgres";
    group = "postgres";
  };

  services.postgresql = {
    enable = true;
    port = 22002;
    enableTCPIP = false;
    initialScript = config.age.secrets.initDatabase.path;
  };

  services.postgresqlBackup = {
    enable = true;
    location = "/persist/var/backup/postgresql";
    databases = [ "firefly" ];
    startAt = "*-*-* 01:15:00";
  };

  environment.persist.directories = [
    config.services.postgresql.dataDir
  ];
}
