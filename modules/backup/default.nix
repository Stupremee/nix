{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) length;

  cfg = config.my.backup;
in
{
  options.my.backup = with lib; {
    enable = mkEnableOption "Enable the backups";
  };

  options.my.backups =
    with lib;
    mkOption {
      default = { };
      type = types.attrsOf (
        types.submodule (
          { ... }:
          {
            options = {
              dynamicFilesFrom = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = ''
                  A script that produces a list of files to back up.  The
                  results of this command are given to the '--files-from'
                  option.
                '';
              };

              paths = mkOption {
                type = types.nullOr (types.listOf types.str);
                default = null;
                description = ''
                  Which paths to backup.  If null or an empty array, no
                  backup command will be run.  This can be used to create a
                  prune-only job.
                '';
                example = [
                  "/var/lib/postgresql"
                  "/home/user/backup"
                ];
              };

              user = mkOption {
                type = types.str;
                default = "root";
                description = ''
                  As which user the backup should run.
                '';
              };

              timerConfig = mkOption {
                type = types.attrs;
                default = {
                  OnCalendar = "daily";
                };

                description = ''
                  When to run the backup. See man systemd.timer for details.
                '';

                example = {
                  OnCalendar = "00:05";
                  RandomizedDelaySec = "5h";
                };
              };
            };
          }
        )
      );
    };

  config = lib.mkIf (cfg.enable && (length (lib.attrNames config.my.backups)) != 0) {
    age.secrets.resticPassword.rekeyFile = ../../secrets/restic-password;
    age.secrets.rcloneConf.rekeyFile = ../../secrets/rclone.conf;

    services.restic.backups = lib.mapAttrs' (
      name: value:
      lib.nameValuePair name (
        {
          repository = "rclone:Backup:stus-backups/${config.system.name}/${name}";
          initialize = true;

          passwordFile = config.age.secrets.resticPassword.path;
          rcloneConfigFile = config.age.secrets.rcloneConf.path;
        }
        // value
      )
    ) config.my.backups;
  };
}
