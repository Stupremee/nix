{config, ...}: {
  age.secrets."mail@stu-dev.me".file = ../secrets/password/mail-at-stu-dev.me;

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "justus.k@protonmail.com";

  mailserver = {
    enable = true;
    fqdn = "mail.stu-dev.me";
    domains = ["stu-dev.me"];

    loginAccounts = {
      "mail@stu-dev.me" = {
        hashedPasswordFile = config.age.secrets."mail@stu-dev.me".path;
      };
    };

    certificateScheme = 3;
  };
}
