{ config, pkgs, ... }:
let
  inherit (builtins) toString;

  cfg = config.services.paperless-ng;

  gotenbergPort = toString 22000;
  tikaPort = toString 22001;
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

      #PAPERLESS_TIKA_ENABLED = true;
      #PAPERLESS_TIKA_ENDPOINT = "http://localhost:${tikaPort}";
      #PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://localhost:${gotenbergPort}";
    };
  };

  #virtualisation.oci-containers.containers.gotenberg = {
  #user = "gotenberg:gotenberg";
  #image = "thecodingmachine/gotenberg:6";
  #environment.DISABLE_GOOGLE_CHROME = "1";

  #ports = [
  #"127.0.0.1:${gotenbergPort}:3000"
  #];
  #};

  #virtualisation.oci-containers.containers.tika = {
  #image = "apache/tika:2.1.0";

  #ports = [
  #"127.0.0.1:${tikaPort}:9998"
  #];
  #};
}
