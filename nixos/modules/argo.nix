{
  config,
  lib,
  unstable-pkgs,
  pkgs,
  ...
}: let
  inherit (builtins) concatStringsSep toString;
  inherit (lib) mkOption types mkIf mapAttrsToList;

  cfg = config.modules.argo;

  routeOpts = {...}: {
    options = {
      to = mkOption {
        type = types.str;
      };

      toPort = mkOption {
        type = types.int;
      };
    };
  };

  ingressRules =
    mapAttrsToList (name: route: let
      addr =
        if route.toPort != null
        then "http://localhost:${toString route.toPort}"
        else route.to;
    in ''
      - hostname: ${name}
        service: ${addr}
    '')
    cfg.route;

  argoConfig = pkgs.writeText "argo-tunnel.yaml" ''
    tunnel: ${cfg.tunnel.name}
    credentials-file: ${config.age.secrets.argotunnel.path}
    loglevel: warn

    ingress:
    ${concatStringsSep "\n" ingressRules}
    - service: http_status:404
  '';
in {
  options.modules.argo = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    route = mkOption {
      default = {};
      type = with types; attrsOf (submodule routeOpts);
    };

    tunnel = {
      name = mkOption {
        type = types.str;
      };

      credentialsSecret = mkOption {
        type = types.path;
        default = ../../secrets/argotunnel.json;
      };
    };

    user = mkOption {
      type = types.str;
      default = "argo";
    };

    group = mkOption {
      type = types.str;
      default = "argo";
    };
  };

  config = mkIf cfg.enable {
    age.secrets.argotunnel = {
      file = cfg.tunnel.credentialsSecret;
      owner = cfg.user;
      group = cfg.group;
    };

    users = {
      groups."${cfg.group}".name = cfg.group;

      users = {
        "${cfg.user}" = {
          home = "/var/lib/${cfg.user}";
          createHome = true;
          isSystemUser = true;
          group = "${cfg.group}";
        };
      };
    };

    boot.kernel.sysctl = {
      "net.core.rmem_max" = 2500000;
    };

    systemd.services.argotunnel = {
      description = "Cloudflare Argo Tunnel";
      after = ["network-online.target"];
      wants = ["network-online.target"]; # systemd-networkd-wait-online.service
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${unstable-pkgs.cloudflared}/bin/cloudflared --config ${argoConfig} --no-autoupdate tunnel run";
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
        RestartSec = "5s";
        NoNewPrivileges = true;
        LimitNPROC = 512;
        LimitNOFILE = 1048576;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHome = true;
        ProtectSystem = "full";
        ReadWriteDirectories = "/var/lib/${cfg.user}";
      };
    };
  };
}
