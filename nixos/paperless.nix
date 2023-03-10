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

  modules.argo.route."docs.stu-dev.me".toPort = config.services.paperless.port;

  services.paperless = {
    enable = true;
    package = unstable-pkgs.paperless-ngx;
    passwordFile = builtins.toString config.age.secrets.paperlessPassword.path;

    extraConfig = {
      PAPERLESS_URL = "https://docs.stu-dev.me";

      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_TASK_WORKERS = 2;
      PAPERLESS_THREADS_PER_WORKER = 4;

      PAPERLESS_TIKA_ENABLED = true;
      PAPERLESS_TIKA_ENDPOINT = "http://127.0.0.1:${tikaPort}";
      PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://127.0.0.1:${gotenbergPort}";
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
