{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.tailscale;
  isNetworkd = config.networking.useNetworkd;
in {
  meta.maintainers = with maintainers; [danderson mbaillie twitchyliquid64];

  options.modules.tailscale = {
    enable = mkEnableOption (lib.mdDoc "Tailscale client daemon");

    port = mkOption {
      type = types.port;
      default = 41641;
      description = lib.mdDoc "The port to listen on for tunnel traffic (0=autoselect).";
    };

    nginxAuth = mkOption {
      type = types.bool;
      default = false;
    };

    interfaceName = mkOption {
      type = types.str;
      default = "tailscale0";
      description = lib.mdDoc ''The interface name for tunnel traffic. Use "userspace-networking" (beta) to not use TUN.'';
    };

    permitCertUid = mkOption {
      type = types.nullOr types.nonEmptyStr;
      default = null;
      description = lib.mdDoc "Username or user ID of the user allowed to to fetch Tailscale TLS certificates for the node.";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.tailscale;
      defaultText = literalExpression "pkgs.tailscale";
      description = lib.mdDoc "The package to use for tailscale";
    };

    useRoutingFeatures = mkOption {
      type = types.enum ["none" "client" "server" "both"];
      default = "none";
      example = "server";
      description = lib.mdDoc ''
        Enables settings required for Tailscale's routing features like subnet routers and exit nodes.

        To use these these features, you will still need to call `sudo tailscale up` with the relevant flags like `--advertise-exit-node` and `--exit-node`.

        When set to `client` or `both`, reverse path filtering will be set to loose instead of strict.
        When set to `server` or `both`, IP forwarding will be enabled.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [cfg.package]; # for the CLI
    systemd.packages = [cfg.package];
    systemd.services.tailscaled = {
      wantedBy = ["multi-user.target"];
      path = [
        config.networking.resolvconf.package # for configuring DNS in some configs
        pkgs.procps # for collecting running services (opt-in feature)
        pkgs.glibc # for `getent` to look up user shells
      ];
      serviceConfig.Environment =
        [
          "PORT=${toString cfg.port}"
          ''"FLAGS=--tun ${lib.escapeShellArg cfg.interfaceName}"''
        ]
        ++ (lib.optionals (cfg.permitCertUid != null) [
          "TS_PERMIT_CERT_UID=${cfg.permitCertUid}"
        ]);
      # Restart tailscaled with a single `systemctl restart` at the
      # end of activation, rather than a `stop` followed by a later
      # `start`. Activation over Tailscale can hang for tens of
      # seconds in the stop+start setup, if the activation script has
      # a significant delay between the stop and start phases
      # (e.g. script blocked on another unit with a slow shutdown).
      #
      # Tailscale is aware of the correctness tradeoff involved, and
      # already makes its upstream systemd unit robust against unit
      # version mismatches on restart for compatibility with other
      # linux distros.
      stopIfChanged = false;
    };

    boot.kernel.sysctl = mkIf (cfg.useRoutingFeatures == "server" || cfg.useRoutingFeatures == "both") {
      "net.ipv4.conf.all.forwarding" = mkOverride 97 true;
      "net.ipv6.conf.all.forwarding" = mkOverride 97 true;
    };

    networking.firewall.checkReversePath = mkIf (cfg.useRoutingFeatures == "client" || cfg.useRoutingFeatures == "both") "loose";

    networking.dhcpcd.denyInterfaces = [cfg.interfaceName];

    systemd.network.networks."50-tailscale" = mkIf isNetworkd {
      matchConfig = {
        Name = cfg.interfaceName;
      };
      linkConfig = {
        Unmanaged = true;
        ActivationPolicy = "manual";
      };
    };

    systemd.services.tailscale-nginx-auth = mkIf cfg.nginxAuth {
      description = "Tailscale NGINX Authentication service";
      wantedBy = ["caddy.service" "nginx.service"];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/tailscale-nginx-auth";
        DynamicUser = "yes";
      };
    };

    systemd.sockets.tailscale-nginx-auth = mkIf cfg.nginxAuth {
      description = "Tailscale NGINX Authentication socket";
      partOf = ["tailscale-nginx-auth.service"];
      wantedBy = ["sockets.target"];

      socketConfig = {
        ListenStream = "/run/tailscale/nginx-auth.sock";
      };
    };
  };
}
