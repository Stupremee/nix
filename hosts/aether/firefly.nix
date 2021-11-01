{ config, pkgs, ... }:
let
  port = 22002;

  sqlCfg = config.services.mysql;
in
{
  age.secrets.fireflyEnv.file = ../../secrets/firefly.env;

  virtualisation.oci-containers.containers.firefly = {
    image = "fireflyiii/core:latest";
    environmentFiles = [ config.age.secrets.fireflyEnv.path ];
    extraOptions = [ "--network" "host" ];
  };

  age.secrets.initDatabase = {
    file = ../../secrets/initDatabase.sql;
    owner = sqlCfg.user;
    group = sqlCfg.group;
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    bind = "127.0.0.1";
    port = 22002;
    dataDir = "/persist/var/lib/mysql";
    initialScript = config.age.secrets.initDatabase.path;
  };

  services.mysqlBackup = {
    enable = true;
    location = "/persist/var/backup/mysql";
    calendar = "daily";
    databases = [ "firefly" ];
  };
}
