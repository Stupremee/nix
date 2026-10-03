{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.my.cliproxyapi;
  service = config.services.cliproxyapi;

  stateDirectory = service.stateDir;
  apiProxyPort = 8318;

  # Roots that only exist in the v8 config layout (see config.example.yaml).
  v8Detect = concatMapStringsSep " or " (key: ''has("${key}")'') [
    "config-version"
    "server"
    "management"
    "access"
    "credentials"
    "requests"
    "oauth"
    "upstream"
    "multimedia"
    "observability"
  ];

  # Block-style YAML sequence, so yq writes it like the rest of the file.
  tailscaleTagsYaml = concatMapStrings (tag: "- ${builtins.toJSON tag}\n") cfg.tailscaleAllowedTags;

  # Sets the Nix-owned keys in the otherwise mutable config.yaml. Caddy on
  # loopback is the trusted proxy, so tailnet auth sees the client it forwards
  # for cliproxy.jukl.dev. Runs as root
  # in stateDirectory before every start; files it creates take the
  # directory's owner (the service user).
  migrate = pkgs.writeShellScript "cliproxyapi-migrate" ''
    set -eu
    umask 077
    yq=${getExe pkgs.yq-go}
    owner="$(stat -c %u:%g .)"

    # Docker mounted auth/ at /root/.cli-proxy-api.
    export AUTH_DIR=${stateDirectory}/auth
    export TAGS=${escapeShellArg tailscaleTagsYaml}
    edits='
      with(select(.["auth-dir"] == "/root/.cli-proxy-api"); .["auth-dir"] = strenv(AUTH_DIR)) |
      with(select(.oauth["auth-dir"] == "/root/.cli-proxy-api"); .oauth["auth-dir"] = strenv(AUTH_DIR)) |'
    if [ "$($yq '${v8Detect} or (.["api-keys"] | tag == "!!map")' config.yaml)" = true ]; then
      edits="$edits"'
        .server["trusted-proxies"] = ["127.0.0.1"] |
        .management.tailscale.enable = true |
        .management.tailscale["allowed-tags"] = env(TAGS) |
        .observability.usage.analysis.enable = true'
    else
      edits="$edits"'
        .["trusted-proxies"] = ["127.0.0.1"] |
        .["remote-management"].tailscale.enable = true |
        .["remote-management"].tailscale["allowed-tags"] = env(TAGS) |
        .["usage-analysis"].enable = true'
    fi

    $yq "$edits" config.yaml > config.yaml.new
    # Compare content, not formatting, so an up-to-date file is left untouched.
    if [ "$($yq -o json config.yaml)" = "$($yq -o json config.yaml.new)" ]; then
      rm config.yaml.new
    else
      chown "$owner" config.yaml.new
      mv config.yaml.new config.yaml
      echo "cliproxyapi-migrate: updated Nix-owned keys in config.yaml"
    fi
  '';
in
{
  options.my.cliproxyapi = {
    enable = mkEnableOption "Enable CLIProxyAPI";

    port = mkOption {
      type = types.port;
      default = 8317;
      description = "CLIProxyAPI listen port, reachable from loopback and the tailnet";
    };

    tailnetDomain = mkOption {
      type = types.str;
      default = "cliproxy.jukl.dev";
      description = "HTTPS hostname for the API and panel; resolves to rome's tailnet address";
    };

    tailscaleAllowedTags = mkOption {
      type = types.listOf types.str;
      default = [ "tag:laptop" ];
      description = "Tailnet tags allowed to use the management panel without the management key";
    };
  };

  config = mkIf cfg.enable {
    my = {
      cloudflare-tunnel.enable = true;

      persist.directories = [
        {
          directory = stateDirectory;
          user = "cliproxyapi";
          group = "cliproxyapi";
          mode = "0700";
        }
      ];
      backups.cliproxyapi.paths = [ stateDirectory ];
    };

    # Listens on all interfaces: rome's firewall only trusts tailscale0, so
    # LAN clients are blocked while Caddy and tailnet peers get through.
    services.cliproxyapi = {
      enable = true;
      inherit (cfg) port;
    };

    systemd.services.cliproxyapi.serviceConfig.ExecStartPre = mkAfter [ "+${migrate}" ];

    services.caddy.virtualHosts = {
      "http://:${toString apiProxyPort}".extraConfig = ''
        bind 127.0.0.1

        @administrative path /management.html /v0/management /v0/management/* /v8/management /v8/management/* /v0/resource/plugins/*
        respond @administrative 404

        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';

      ${cfg.tailnetDomain}.extraConfig = ''
        # Caddy's Cloudflare token only covers stu-dev.me, so
        # _acme-challenge.<domain> is a CNAME to this name in that zone.
        tls {
          dns cloudflare {env.CLOUDFLARE_API_TOKEN}
          resolvers 1.1.1.1 1.0.0.1
          dns_challenge_override_domain _acme-challenge.${
            replaceStrings [ "." ] [ "-" ] cfg.tailnetDomain
          }.stu-dev.me
        }

        # Browsers opening the bare hostname land on the panel; API clients
        # don't send Accept: text/html.
        @browserRoot {
          path /
          header Accept *text/html*
        }
        redir @browserRoot /management.html

        @pluginResources path /v0/resource/plugins/*
        respond @pluginResources 404

        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';

    };
  };
}
