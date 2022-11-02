{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
with lib; let
  inherit (utils.systemdUtils.unitOptions) unitOption;
  inherit (builtins) length;

  cfg = config.modules.backups;
in {
  options.modules.backups = mkOption {
    default = {};
    type = types.attrsOf (types.submodule ({...}: {
      options = {
        dynamicFilesFrom = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            A script that produces a list of files to back up.  The
            results of this command are given to the '--files-from'
            option.
          '';
          example = "find /home/matt/git -type d -name .git";
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
          example = "postgresql";
        };

        timerConfig = mkOption {
          type = types.attrsOf unitOption;
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
    }));
  };

  config = mkIf ((length (lib.attrNames cfg)) != 0) {
    age.secrets.resticPassword.file = ../../secrets/password/restic;
    age.secrets.rcloneConf.file = ../../secrets/rclone.conf;

    services.restic.backups =
      mapAttrs'
      (name: value:
        nameValuePair name
        ({
            repository = "rclone:gdrive:/Backups/${config.system.name}/${name}";
            initialize = true;

            passwordFile = config.age.secrets.resticPassword.path;
            rcloneConfigFile = config.age.secrets.rcloneConf.path;
          }
          // value))
      cfg;
  };
}
