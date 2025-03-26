{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  inherit (builtins) toString;

  cfg = config.my.oidc;
in
{
  options.my.oidc = {
    enable = mkEnableOption "Enable authelia OIDC provider and LLDAP";

    clients = mkOption {
      default = { };
      type = types.attrsOf (
        types.submodule (
          { ... }:
          {
            options = {
              name = mkOption {
                type = types.str;
              };

              secret = mkOption {
                type = types.str;
              };

              authorization_policy = mkOption {
                type = types.str;
                default = "one_factor";
              };

              scopes = mkOption {
                type = types.listOf types.str;
                default = [
                  "openid"
                  "profile"
                ];
              };

              redirect_uris = mkOption {
                type = types.listOf types.str;
              };
            };
          }
        )
      );
    };
  };

  config = mkIf cfg.enable {
    age.secrets =
      let
        secret =
          attrs:
          {
            owner = "authelia-main";
            group = "authelia-main";
          }
          // attrs;
      in
      {
        lldap-env.rekeyFile = ../../../secrets/lldap.env.age;

        authelia-private-key = secret { rekeyFile = ../../../secrets/authelia-private-key.age; };
        authelia-ldap-user-password = secret {
          rekeyFile = ../../../secrets/authelia-ldap-user-password.age;
        };
        authelia-storage-encryption-key = secret { generator.script = "alnum"; };
        authelia-jwt-secret = secret { generator.script = "alnum"; };
        authelia-session-secret = secret { generator.script = "alnum"; };
        authelia-hmac-secret = secret { generator.script = "alnum"; };
      };

    services.caddy.virtualHosts."ldap.stu-dev.me".extraConfig = ''
      import cloudflare
      reverse_proxy :${toString config.services.lldap.settings.http_port}
    '';

    services.caddy.virtualHosts."auth.stu-dev.me".extraConfig = ''
      import cloudflare
      reverse_proxy :9091
    '';

    services.authelia.instances.main = {
      enable = true;

      secrets = {
        storageEncryptionKeyFile = config.age.secrets.authelia-storage-encryption-key.path;
        jwtSecretFile = config.age.secrets.authelia-jwt-secret.path;
        sessionSecretFile = config.age.secrets.authelia-session-secret.path;
        oidcHmacSecretFile = config.age.secrets.authelia-hmac-secret.path;
        oidcIssuerPrivateKeyFile = config.age.secrets.authelia-private-key.path;
      };

      settings = {
        theme = "auto";
        default_2fa_method = "webauthn";
        log.level = "warn";

        authentication_backend = {
          refresh_interval = "1m";
          ldap = {
            implementation = "lldap";
            address = "ldap://127.0.0.1:${toString config.services.lldap.settings.ldap_port}";
            base_dn = config.services.lldap.settings.ldap_base_dn;
            user = "uid=authelia-reader,ou=people,dc=stu-dev,dc=me";
            users_filter = "(&(|({username_attribute}={input})({mail_attribute}={input}))(objectClass=person))";
          };
        };

        session = {
          cookies = [
            {
              name = "authelia_session";
              domain = "stu-dev.me";
              authelia_url = "https://auth.stu-dev.me";
              expiration = "1h";
              inactivity = "10m";
              remember_me = "1M";
            }
          ];
        };

        storage.local.path = "/var/lib/authelia-main/database.db";

        notifier.smtp = {
          address = "smtp://localhost:25";
          sender = "Authelia <mail@stu-dev.me>";
          subject = "[Authelia] {title}";
          disable_require_tls = true;
        };

        access_control = {
          default_policy = "deny";
          rules = [
            {
              domain = "*.stu-dev.me";
              policy = "one_factor";
            }
          ];
        };

        identity_providers.oidc.clients = mapAttrsToList (id: cfg: {
          client_id = id;
          client_name = cfg.name;
          client_secret = cfg.secret;

          inherit (cfg) authorization_policy scopes redirect_uris;

          public = false;
          require_pkce = true;
          pkce_challenge_method = "S256";
          userinfo_signed_response_alg = "none";
          token_endpoint_auth_method = "client_secret_basic";
        }) cfg.clients;
      };

      environmentVariables = {
        AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE =
          config.age.secrets.authelia-ldap-user-password.path;
      };
    };

    services.lldap = {
      enable = true;
      environmentFile = config.age.secrets.lldap-env.path;

      settings = {
        http_url = "https://ldap.stu-dev.me";
        ldap_base_dn = "dc=stu-dev,dc=me";
      };
    };

    my.backups.lldap =
      let
        path = "/var/lib/lldap";
      in
      {
        dynamicFilesFrom = ''
          mkdir -p ${path}/backups
          ${pkgs.sqlite}/bin/sqlite3 ${path}/users.db ".backup '${path}/backups/users.db'"
          echo ${path}/backups/
        '';

        backupCleanupCommand = ''
          rm -rf ${path}/backups/users.db
        '';
      };

    my.persist.directories = [
      "/var/lib/private/lldap"
      "/var/lib/authelia-main"
    ];
  };
}
