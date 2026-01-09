{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib;
let
  inherit (builtins) toString;

  cfg = config.my.paperless;
in
{
  options.my.paperless = {
    enable = mkEnableOption "Enable paperless-ngx";
  };

  config = mkIf cfg.enable {
    age.secrets.paperless-env.rekeyFile = ../../../secrets/paperless.env.age;
    age.secrets.paperlessPassword = {
      generator.script = "alnum";
      owner = "paperless";
      group = "paperless";
    };

    services.caddy.virtualHosts."docs.stu-dev.me".extraConfig = ''
      import cloudflare
      reverse_proxy :${toString config.services.paperless.port}
    '';

    services.paperless = {
      enable = true;
      passwordFile = toString config.age.secrets.paperlessPassword.path;
      dataDir = if config.my.persist.enable then "/persist/var/lib/paperless" else "/var/lib/paperless";

      settings = {
        PAPERLESS_URL = "https://docs.stu-dev.me";

        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        # PAPERLESS_TASK_WORKERS = 4;
        # PAPERLESS_THREADS_PER_WORKER = 8;

        PAPERLESS_TASK_WORKERS = 1;
        PAPERLESS_THREADS_PER_WORKER = 1;

        PAPERLESS_TIKA_ENABLED = true;
        PAPERLESS_TIKA_ENDPOINT = "http://127.0.0.1:${toString config.services.tika.port}";
        PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://127.0.0.1:${toString config.services.gotenberg.port}";

        PAPERLESS_CONSUMER_ENABLE_BARCODES = true;
        PAPERLESS_CONSUMER_ENABLE_ASN_BARCODE = true;
        PAPERLESS_CONSUMER_BARCODE_UPSCALE = "1.5";
        PAPERLESS_CONSUMER_BARCODE_DPI = 600;
        PAPERLESS_CONSUMER_BARCODE_SCANNER = "ZXING";

        # Check mail every 5 minutes
        PAPERLESS_EMAIL_TASK_CRON = "*/5 * * * *";

        PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
        # PAPERLESS_SOCIALACCOUNT_PROVIDERS is provided by secret environment file
        PAPERLESS_DISABLE_REGULAR_LOGIN = true;
      };
    };

    systemd.services = {
      paperless-consumer.serviceConfig.EnvironmentFile = config.age.secrets.paperless-env.path;
      paperless-scheduler.serviceConfig.EnvironmentFile = config.age.secrets.paperless-env.path;
      paperless-task-queue.serviceConfig.EnvironmentFile = config.age.secrets.paperless-env.path;
      paperless-web.serviceConfig.EnvironmentFile = config.age.secrets.paperless-env.path;
    };

    my.oidc.clients.paperless = {
      secret = "$pbkdf2-sha512$310000$jTGxRtvejw4PcV.Z35dOZg$tFOu8151UQxuxfTH/Q8fFi1/fiJqTX.DQt.qvdJLODNbNzytYI2f9Sc./.nvpZ5Q5YWFQCPbakW5uHxY29nWJw";
      name = "Paperless";
      redirect_uris = [ "https://docs.stu-dev.me/accounts/oidc/authelia/login/callback/" ];
      scopes = [
        "openid"
        "profile"
        "email"
        "groups"
      ];
    };

    my.backups.paperless =
      let
        path = config.services.paperless.dataDir;
      in
      {
        dynamicFilesFrom = ''
          mkdir -p ${path}/exported
          ${path}/paperless-manage document_exporter ${path}/exported
          echo ${path}/exported/
        '';

        backupCleanupCommand = ''
          rm -rf ${path}/exported
        '';
      };

    services.gotenberg = {
      enable = true;
    };

    services.tika = {
      enable = true;
    };
  };
}
