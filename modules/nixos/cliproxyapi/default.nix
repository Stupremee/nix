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
  adminProxyPort = 8319;

  # Left behind by the removed CPA Usage Keeper container; imported once into
  # the native Analysis store.
  keeperDatabase = "/var/lib/cpa-usage-keeper/data/app.db";

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

  # Sets the Nix-owned keys in the otherwise mutable config.yaml and runs the
  # one-time Keeper import. Runs as root in stateDirectory before every start;
  # files it creates take the directory's owner (the service user).
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
        .management.tailscale.enable = true |
        .management.tailscale["allowed-tags"] = env(TAGS) |
        .observability.usage.analysis.enable = true'
    else
      edits="$edits"'
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

    if [ -e ${keeperDatabase} ] && [ ! -e .keeper-imported ]; then
      tmp="$(mktemp -d)"
      trap 'rm -rf "$tmp"' EXIT
      cp ${keeperDatabase}* "$tmp"/
      chown -R "$owner" "$tmp"
      # The import logs errors but exits 0, so success is detected from its summary line.
      out="$(HOME="$PWD" ${pkgs.util-linux}/bin/setpriv --reuid="''${owner%:*}" --regid="''${owner#*:}" --clear-groups \
        ${getExe service.package} --config config.yaml --import-keeper-db "$tmp/app.db" 2>&1)" || true
      echo "$out"
      case "$out" in
        *"Imported "*) touch .keeper-imported && chown "$owner" .keeper-imported ;;
        *) echo "cliproxyapi-migrate: Keeper import failed; retrying on next start" ;;
      esac
    fi
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
      description = "CLIProxyAPI listen port, reachable from loopback and the tailnet";
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
        # Keeps the old Keeper data mounted for the one-time import. Remove
        # together with the data once logs/usage-analysis.db holds the history.
        "/var/lib/cpa-usage-keeper"
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

      "http://:${toString adminProxyPort}".extraConfig = ''
        bind 127.0.0.1

        # Plugin browser resources bypass CLIProxyAPI's management-key middleware,
        # and the features they provided are native now.
        @pluginResources path /v0/resource/plugins/*
        respond @pluginResources 404

        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
