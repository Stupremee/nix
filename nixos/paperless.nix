{ config, pkgs, unstable-pkgs, ... }: {
  age.secrets.paperlessPassword.file = ../secrets/password/paperless;
  age.secrets.resticPassword.file = ../secrets/password/restic;
  age.secrets.rcloneConf.file = ../secrets/rclone.conf;

  services.paperless = {
    enable = true;
    package = unstable-pkgs.paperless-ngx;
    passwordFile = builtins.toString config.age.secrets.paperlessPassword.path;
  };

  services.restic.backups.paperless = {
    repository = "rclone:gdrive:/Backups/paperless";
    initialize = true;

    passwordFile = config.age.secrets.resticPassword.path;
    rcloneConfigFile = config.age.secrets.rcloneConf.path;

    dynamicFilesFrom =
      let
        path = config.services.paperless.dataDir;
      in
      ''
        mkdir -p ${path}/exported
        ${path}/paperless-manage document_exporter ${path}/exported
        echo ${path}/exported/
      '';

    # Perform daily backups
    timerConfig = {
      OnCalendar = "daily";
    };
  };

  services.nginx.virtualHosts = {
    "docs.stu-dev.me" = {
      locations."/".proxyPass = "http://127.0.0.1:${builtins.toString config.services.paperless.port}";

      onlySSL = true;

      sslCertificate = config.age.secrets."cert/stu-dev.me.pem".path;
      sslCertificateKey = config.age.secrets."cert/stu-dev.me.key".path;
    };
  };
}
