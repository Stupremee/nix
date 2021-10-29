{ config, ... }: {
  age.secrets.importantPassword.file = ../../secrets/restic-important;
  age.secrets.rcloneConf.file = ../../secrets/rclone.conf;

  services.restic = {
    # Backup for important data
    backups.important = {
      repository = "rclone:gdrive:/Backups/aether";
      initialize = true;

      passwordFile = config.age.secrets.importantPassword.path;
      rcloneConfigFile = config.age.secrets.rcloneConf.path;

      paths = [
        "/var/lib/bitwarden_rs"
        config.services.paperless-ng.dataDir
        config.services.mysqlBackup.location
      ];

      # Perform daily backups
      timerConfig = {
        OnCalendar = "daily";
      };
    };
  };
}
