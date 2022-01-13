{ pkgs, config, ... }:
let
  inherit (builtins) listToAttrs toPath;

  mails = [
    "mail@stu-dev.me"
    "csgo@stu-dev.me"
  ];

  passwordSecrets = listToAttrs (map
    (mail: {
      name = "${mail}";
      value = {
        file = toPath "${../../secrets/mails}/${mail}";
      };
    })
    mails);
in
{
  age.secrets = passwordSecrets;

  mailserver = {
    enable = true;
    fqdn = "mail.stu-dev.me";
    domains = [ "stu-dev.me" ];

    # A list of all login accounts. To create the password hashes, use
    # nix shell nixpkgs#apacheHttpd -c htpasswd -nbB "" "super secret password" | cut -d: -f2
    loginAccounts = listToAttrs (map
      (mail: {
        name = mail;
        value = {
          hashedPasswordFile = config.age.secrets."${mail}".path;
        };
      })
      mails);

    certificateScheme = 1;
    certificateFile = config.age.secrets."cert/stu-dev.me.pem".path;
    keyFile = config.age.secrets."cert/stu-dev.me.key".path;

    localDnsResolver = false;

    # Enable IMAP and POP3
    enableImap = true;
    enablePop3 = true;
    enableImapSsl = true;
    enablePop3Ssl = true;

    # Enable the ManageSieve protocol
    enableManageSieve = true;
  };

  services.roundcube = {
    enable = true;
    hostName = "webmail.stu-dev.me";
  };

  services.nginx.virtualHosts."webmail.stu-dev.me" = {
    onlySSL = true;
    forceSSL = false;
    enableACME = false;

    sslCertificate = config.age.secrets."cert/stu-dev.me.pem".path;
    sslCertificateKey = config.age.secrets."cert/stu-dev.me.key".path;
  };
}
