{ lib, config, ... }:
let
  dataDir =
    if config.modules.eraseDarlings.enable
    then "${toString config.modules.eraseDarlings.persistDir}/var/lib/postgresql/${config.services.postgresql.package.psqlSchema}"
    else "/var/lib/postgresql/${config.services.postgresql.package.psqlSchema}";
in
{
  services.postgresql = {
    enable = true;

    inherit dataDir;
  };

  systemd.services.postgresql-create-directory = lib.mkIf config.modules.eraseDarlings.enable {
    description = "PostgreSQL setup for creating it's home directory";

    before = [ "postgresql.target" ];
    wantedBy = [ "multi-user.target" "postgresql.target" ];
    after = [ "network.target" ];

    environment.PGDATA = dataDir;

    script = ''
      mkdir -p ${dataDir}
      chown postgres:postgres ${dataDir}
      chmod 0750 ${dataDir}
    '';

    serviceConfig.Type = "oneshot";
  };
}
