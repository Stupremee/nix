{ config, unstable-pkgs, ... }: {
  age.secrets.paperlessPassword.file = ../secrets/password/paperless;

  services.paperless = {
    enable = true;
    package = unstable-pkgs.paperless-ngx;
    passwordFile = builtins.toString config.age.secrets.paperlessPassword.path;
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
