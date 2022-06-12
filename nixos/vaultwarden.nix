{ config, ... }:
let
  cfg = config.modules.vaultwarden;
in
{
  age.secrets.vaultwardenEnv = {
    file = ../secrets/vaultwarden.env;
    owner = "vaultwarden";
    group = "vaultwarden";
  };

  modules.vaultwarden = {
    enable = true;

    environmentFile = config.age.secrets.vaultwardenEnv.path;
    dbBackend = "postgresql";

    config = {
      domain = "https://pw.stu-dev.me";
      signupsAllowed = false;

      rocketAddress = "127.0.0.1";
      rocketPort = 33003;

      databaseUrl = "postgres:///vaultwarden?host=/var/run/postgresql";
    };
  };

  modules.backups.vaultwarden.paths = [
    config.modules.vaultwarden.dataDir
    config.age.secrets.vaultwardenEnv.path
  ];

  services.nginx.virtualHosts = {
    "bw.stu-dev.me" = {
      locations."/".proxyPass = "http://127.0.0.1:${builtins.toString cfg.config.rocketPort}";

      onlySSL = true;

      sslCertificate = config.age.secrets."cert/stu-dev.me.pem".path;
      sslCertificateKey = config.age.secrets."cert/stu-dev.me.key".path;
    };
  };

  services.postgresql.ensureDatabases = [ "vaultwarden" ];
  services.postgresql.ensureUsers = [{
    name = "vaultwarden";
    ensurePermissions = {
      "DATABASE \"vaultwarden\"" = "ALL PRIVILEGES";
      "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
    };
  }];
}
