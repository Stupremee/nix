{
  config,
  pkgs,
  ...
}: {
  age.secrets."mail@stu-dev.me".file = ../secrets/password/mail-at-stu-dev.me;
  age.secrets."docs@stu-dev.me".file = ../secrets/password/docs-at-stu-dev.me;
  age.secrets."monitoring@stu-dev.me".file = ../secrets/password/monitoring-at-stu-dev.me;

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "justus.k@protonmail.com";

  mailserver = let
    certOrKey = ext: ''
      ${config.services.caddy.dataDir}/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/mail.stu-dev.me/mail.stu-dev.me.${ext}
    '';
  in {
    enable = true;
    fqdn = "mail.stu-dev.me";
    domains = ["stu-dev.me"];

    loginAccounts = {
      "mail@stu-dev.me" = {
        hashedPasswordFile = config.age.secrets."mail@stu-dev.me".path;
      };

      "docs@stu-dev.me" = {
        hashedPasswordFile = config.age.secrets."docs@stu-dev.me".path;
      };

      "monitoring@stu-dev.me" = {
        hashedPasswordFile = config.age.secrets."monitoring@stu-dev.me".path;
      };
    };

    certificateScheme = "manual";
    certificateFile = certOrKey "crt";
    keyFile = certOrKey "key";
  };

  modules.roundcube = {
    enable = true;
    hostName = "mail.stu-dev.me";
    dicts = with pkgs.aspellDicts; [en de];
  };

  modules.backups.mail.paths = [
    config.mailserver.mailDirectory
  ];
}
