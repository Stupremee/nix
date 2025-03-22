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
        PAPERLESS_TASK_WORKERS = 4;
        PAPERLESS_THREADS_PER_WORKER = 8;

        PAPERLESS_TIKA_ENABLED = true;
        PAPERLESS_TIKA_ENDPOINT = "http://127.0.0.1:${toString config.services.tika.port}";
        PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://127.0.0.1:${toString config.services.gotenberg.port}";

        PAPERLESS_CONSUMER_ENABLE_BARCODES = true;
        PAPERLESS_CONSUMER_ENABLE_ASN_BARCODE = true;
        PAPERLESS_CONSUMER_BARCODE_UPSCALE = "1.5";
        PAPERLESS_CONSUMER_BARCODE_DPI = 600;

        # Check mail every 5 minutes
        PAPERLESS_EMAIL_TASK_CRON = "*/5 * * * *";
      };
    };

    my.backups.paperless.dynamicFilesFrom =
      let
        path = config.services.paperless.dataDir;
      in
      ''
        mkdir -p ${path}/exported
        ${path}/paperless-manage document_exporter ${path}/exported
        echo ${path}/exported/
      '';

    services.gotenberg = {
      enable = true;
    };

    services.tika = {
      enable = true;
    };
  };
}
