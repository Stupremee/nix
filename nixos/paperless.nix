{
  config,
  unstable-pkgs,
  ...
}: let
  tikaPort = "33001";
  gotenbergPort = "33002";
in {
  age.secrets.paperlessPassword = {
    file = ../secrets/password/paperless;
    owner = "paperless";
    group = "paperless";
  };

  services.caddy.virtualHosts."docs.stu-dev.me".extraConfig = ''
    reverse_proxy :${builtins.toString config.services.paperless.port}
  '';

  services.paperless = {
    enable = true;
    package = unstable-pkgs.paperless-ngx;
    passwordFile = builtins.toString config.age.secrets.paperlessPassword.path;

    settings = {
      PAPERLESS_URL = "https://docs.stu-dev.me";

      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_TASK_WORKERS = 4;
      PAPERLESS_THREADS_PER_WORKER = 8;

      PAPERLESS_TIKA_ENABLED = true;
      PAPERLESS_TIKA_ENDPOINT = "http://127.0.0.1:${tikaPort}";
      PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://127.0.0.1:${gotenbergPort}";

      PAPERLESS_EMAIL_TASK_CRON = "*/5 * * * *";
    };
  };

  modules.backups.paperless.dynamicFilesFrom = let
    path = config.services.paperless.dataDir;
  in ''
    mkdir -p ${path}/exported
    ${path}/paperless-manage document_exporter ${path}/exported
    echo ${path}/exported/
  '';

  virtualisation.oci-containers.containers.gotenberg = {
    user = "gotenberg:gotenberg";
    image = "gotenberg/gotenberg:7.8.1";

    cmd = ["gotenberg" "--chromium-disable-javascript=true" "--chromium-allow-list=file:///tmp/.*"];

    ports = [
      "127.0.0.1:${gotenbergPort}:3000"
    ];
  };

  virtualisation.oci-containers.containers.tika = {
    image = "apache/tika:2.4.0";

    ports = [
      "127.0.0.1:${tikaPort}:9998"
    ];
  };
}
