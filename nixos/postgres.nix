{
  lib,
  config,
  pkgs,
  ...
}: let
  dataDir =
    if config.modules.eraseDarlings.enable
    then "${toString config.modules.eraseDarlings.persistDir}/var/lib/postgresql/${config.services.postgresql.package.psqlSchema}"
    else "/var/lib/postgresql/${config.services.postgresql.package.psqlSchema}";
in {
  services.postgresql = {
    enable = true;

    inherit dataDir;
  };

  systemd.tmpfiles.rules = lib.optionals config.modules.eraseDarlings.enable [
    "d '${dataDir}' 0750 postgres postgres - -"
  ];

  modules.backups.postgresql = let
    inherit (builtins) attrValues;

    compressSuffix = ".zstd";
    compressCmd = "${pkgs.zstd}/bin/zstd -c";

    baseDir = "/tmp/postgres-backup";

    mkSqlPath = prefix: suffix: "/${baseDir}/all${prefix}.sql${suffix}";
    curFile = mkSqlPath "" compressSuffix;
    prevFile = mkSqlPath ".prev" compressSuffix;
    inProgressFile = mkSqlPath ".in-progress" compressSuffix;
  in {
    dynamicFilesFrom = ''
      set -e -o pipefail

      mkdir -p ${baseDir}

      umask 0077 # ensure backup is only readable by postgres user

      if [ -e ${curFile} ]; then
        rm -f ${prevFile}
        mv ${curFile} ${prevFile}
      fi

      ${config.security.sudo.package}/bin/sudo -u postgres ${config.services.postgresql.package}/bin/pg_dumpall \
        | ${compressCmd} \
        > ${inProgressFile}

      mv ${inProgressFile} ${curFile}

      echo ${curFile}
    '';
  };
}
