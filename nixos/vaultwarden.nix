{
  config,
  unstable-pkgs,
  ...
}: {
  age.secrets.vaultwardenEnv = {
    file = ../secrets/vaultwarden.env;
    owner = "vaultwarden";
    group = "vaultwarden";
  };

  services.vaultwarden = {
    enable = true;
    package = unstable-pkgs.vaultwarden;

    environmentFile = config.age.secrets.vaultwardenEnv.path;
    dbBackend = "postgresql";

    config = {
      domain = "https://bw.stu-dev.me";
      signupsAllowed = false;

      rocketAddress = "127.0.0.1";
      rocketPort = 33003;

      databaseUrl = "postgres:///vaultwarden?host=/var/run/postgresql";
    };
  };

  modules.backups.vaultwarden.paths = [
    "/var/lib/bitwarden_rs"
    config.age.secrets.vaultwardenEnv.path
  ];

  services.caddy.virtualHosts."bw.stu-dev.me".extraConfig = ''
    reverse_proxy :${builtins.toString config.services.vaultwarden.config.rocketPort}
  '';

  services.postgresql.ensureDatabases = ["vaultwarden"];
  services.postgresql.ensureUsers = [
    {
      name = "vaultwarden";
      ensureDBOwnership = true;
    }
  ];
}
