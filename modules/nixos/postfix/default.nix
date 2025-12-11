{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.my.postfix;
in
{
  options.my.postfix = {
    enable = mkEnableOption "Enables a locally accessible postfix SMTP server";

    from = mkOption {
      type = types.str;
      description = "The mail from which to send the mails";
      default = "mail@stu-dev.me";
    };
  };

  config = mkIf cfg.enable {
    age.secrets.postfixSaslPasswords = {
      rekeyFile = ../../../secrets/postfix-sasl-passwords.age;
      owner = "postfix";
      group = "postfix";
    };

    services.postfix = {
      enable = true;

      mapFiles.sender_canonical_maps = pkgs.writeText "sender_canonical_maps" "/.+/ ${cfg.from}";
      mapFiles.header_check = pkgs.writeText "header_check" "/From:.*/ REPLACE From: ${config.networking.hostName} <${cfg.from}>";

      settings.main = {
        relayhost = [ "smtp.migadu.com:465" ];

        inet_interfaces = "127.0.0.1";

        smtp_sasl_auth_enable = "yes";
        smtp_tls_wrappermode = "yes";
        smtp_tls_security_level = "encrypt";
        smtp_sasl_security_options = "";
        smtp_sasl_password_maps = "texthash:${config.age.secrets.postfixSaslPasswords.path}";

        sender_canonical_classes = "envelope_sender, header_sender";
        sender_canonical_maps = "regexp:/var/lib/postfix/conf/sender_canonical_maps";
        smtp_header_checks = "regexp:/var/lib/postfix/conf/header_check";
      };
    };

    my.persist.directories = [
      {
        directory = "/var/lib/postfix";
        inherit (config.services.postfix) user group;
      }
    ];
  };
}
