{
  config,
  pkgs,
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

  services.paperless = {
    enable = true;
    passwordFile = builtins.toString config.age.secrets.paperlessPassword.path;

    extraConfig = {
      PAPERLESS_URL = "https://docs.stu-dev.me";

      PAPERLESS_OCR_LANGUAGE = "deu+eng";

      # PAPERLESS_TIKA_ENABLED = true;
      # PAPERLESS_TIKA_ENDPOINT = "http://127.0.0.1:${tikaPort}";
      # PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://127.0.0.1:${gotenbergPort}";
    };
  };

  modules.backups.paperless.dynamicFilesFrom = let
    path = config.services.paperless.dataDir;
  in ''
    mkdir -p ${path}/exported
    ${path}/paperless-manage document_exporter ${path}/exported
    echo ${path}/exported/
  '';

  services.nginx.virtualHosts = {
    "docs.stu-dev.me" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${builtins.toString config.services.paperless.port}";

        extraConfig = ''
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $connection_upgrade;
        '';
      };

      onlySSL = true;

      sslCertificate = config.age.secrets."cert/stu-dev.me.pem".path;
      sslCertificateKey = config.age.secrets."cert/stu-dev.me.key".path;
    };
  };

  # virtualisation.oci-containers.containers.gotenberg = {
  #   user = "gotenberg:gotenberg";
  #   image = "gotenberg/gotenberg:7.5.2";
  #   environment.DISABLE_GOOGLE_CHROME = "1";

  #   ports = [
  #     "127.0.0.1:${gotenbergPort}:3000"
  #   ];
  # };

  # virtualisation.oci-containers.containers.tika = {
  #   image = "apache/tika:2.4.0";

  #   ports = [
  #     "127.0.0.1:${tikaPort}:9998"
  #   ];
  # };
}
