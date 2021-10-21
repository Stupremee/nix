{ config, pkgs, ... }:
let cfg = config.services.paperless-ng;
in
{
  age.secrets.paperlessPassword = {
    file = ../../secrets/paperlessPassword;
    owner = cfg.user;
    group = cfg.user;
    mode = "0600";
  };

  services.paperless-ng = {
    enable = true;
    passwordFile = config.age.secrets.paperlessPassword.path;

    dataDir = "/persist/var/lib/paperless";

    extraConfig = {
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_ADMIN_USER = "stu";
    };
  };
}
