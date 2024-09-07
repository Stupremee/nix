{
  lib,
  config,
  pkgs,
  ...
}: let
  dataDir = "/var/lib/postgresql/${config.services.postgresql.package.psqlSchema}";
in {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;

    inherit dataDir;
  };

  modules.backups.postgresql = let
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
