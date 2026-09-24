{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.my.cliproxyapi;

  stateDirectory = "/var/lib/cliproxyapi";
  apiProxyPort = 8318;
  adminProxyPort = 8319;

  bootstrapConfig = pkgs.writeShellScript "cliproxyapi-bootstrap-config" ''
    set -eu

    install -d -m 0700 ${stateDirectory}
    install -d -m 0700 ${stateDirectory}/auth
    install -d -m 0700 ${stateDirectory}/logs
    install -d -m 0700 ${stateDirectory}/plugins

    if [ -s ${stateDirectory}/config.yaml ]; then
      exit 0
    fi

    cliproxy_credentials_file="${stateDirectory}/bootstrap-credentials"
    if [ ! -s "$cliproxy_credentials_file" ]; then
      cliproxy_api_key="$(${pkgs.openssl}/bin/openssl rand -hex 32)"
      cliproxy_management_key="$(${pkgs.openssl}/bin/openssl rand -hex 32)"
      cliproxy_credentials_tmp="$(${pkgs.coreutils}/bin/mktemp ${stateDirectory}/bootstrap-credentials.XXXXXX)"
      chmod 0600 "$cliproxy_credentials_tmp"
      {
        echo "CLIPROXY_API_KEY=$cliproxy_api_key"
        echo "CLIPROXY_MANAGEMENT_KEY=$cliproxy_management_key"
      } > "$cliproxy_credentials_tmp"
      mv "$cliproxy_credentials_tmp" "$cliproxy_credentials_file"
    fi

    . "$cliproxy_credentials_file"
    cliproxy_api_key="$CLIPROXY_API_KEY"
    cliproxy_management_key="$CLIPROXY_MANAGEMENT_KEY"
    cliproxy_config_tmp="$(${pkgs.coreutils}/bin/mktemp ${stateDirectory}/config.yaml.XXXXXX)"
    chmod 0600 "$cliproxy_config_tmp"

    {
      echo 'host: ""'
      echo 'port: ${toString cfg.port}'
      echo
      echo 'tls:'
      echo '  enable: false'
      echo '  cert: ""'
      echo '  key: ""'
      echo
      echo 'remote-management:'
      echo '  allow-remote: true'
      echo "  secret-key: \"$cliproxy_management_key\""
      echo '  disable-control-panel: false'
      echo
      echo 'auth-dir: "/root/.cli-proxy-api"'
      echo
      echo 'api-keys:'
      echo "  - \"$cliproxy_api_key\""
      echo
      echo 'debug: false'
      echo 'request-log: false'
      echo 'logging-to-file: true'
      echo 'logs-max-total-size-mb: 512'
      echo 'usage-statistics-enabled: false'
      echo
      echo 'pprof:'
      echo '  enable: false'
      echo '  addr: "127.0.0.1:8316"'
      echo
      echo 'ws-auth: true'
      echo
      echo 'plugins:'
      echo '  enabled: false'
      echo '  dir: "plugins"'
    } > "$cliproxy_config_tmp"

    mv "$cliproxy_config_tmp" ${stateDirectory}/config.yaml
  '';
in
{
  options.my.cliproxyapi = {
    enable = mkEnableOption "Enable CLIProxyAPI";

    domain = mkOption {
      type = types.str;
      default = "cliproxy.stu-dev.me";
      description = "Public API hostname";
    };

    adminDomain = mkOption {
      type = types.str;
      default = "cliproxy-admin.stu-dev.me";
      description = "Management hostname; management API requires CLIProxyAPI's management key";
    };

    port = mkOption {
      type = types.port;
      default = 8317;
      description = "Host loopback port for CLIProxyAPI";
    };
  };

  config = mkIf cfg.enable {
    my = {
      cloudflare-tunnel.enable = true;
      docker.enable = true;

      persist.directories = [ stateDirectory ];
      backups.cliproxyapi.paths = [ stateDirectory ];
    };

    systemd.tmpfiles.rules = [
      "d ${stateDirectory} 0700 root root -"
      "d ${stateDirectory}/auth 0700 root root -"
      "d ${stateDirectory}/logs 0700 root root -"
      "d ${stateDirectory}/plugins 0700 root root -"
    ];

    virtualisation.oci-containers.containers.cliproxyapi = {
      image = "eceasy/cli-proxy-api@sha256:238691ac26ce55e4d1c5219d72e3ad74838f81eda26359912eeb415e2820d163";
      ports = [
        "127.0.0.1:${toString cfg.port}:8317"
        "127.0.0.1:1455:1455"
        "127.0.0.1:54545:54545"
      ];
      volumes = [
        "${stateDirectory}/config.yaml:/CLIProxyAPI/config.yaml"
        "${stateDirectory}/auth:/root/.cli-proxy-api"
        "${stateDirectory}/logs:/CLIProxyAPI/logs"
        "${stateDirectory}/plugins:/CLIProxyAPI/plugins"
      ];
    };

    systemd.services.docker-cliproxyapi.preStart = mkBefore ''
      ${bootstrapConfig}
    '';

    services.caddy.virtualHosts = {
      "http://:${toString apiProxyPort}".extraConfig = ''
        bind 127.0.0.1

        @administrative path /management.html /v0/management /v0/management/* /v0/resource/plugins/*
        respond @administrative 404

        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';

      "http://:${toString adminProxyPort}".extraConfig = ''
        bind 127.0.0.1

        # Plugin browser resources bypass CLIProxyAPI's management-key middleware.
        @pluginResources path /v0/resource/plugins/*
        forward_auth @pluginResources localhost:9091 {
          uri /api/authz/forward-auth
          header_up X-Forwarded-Proto https
          copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
        }

        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
