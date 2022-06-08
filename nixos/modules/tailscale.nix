{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tailscale;
  firewallOn = config.networking.firewall.enable;
  rpfMode = config.networking.firewall.checkReversePath;
  rpfIsStrict = rpfMode == true || rpfMode == "strict";
in
{
  options.modules.tailscale = {
    enable = mkEnableOption "Tailscale client daemon";

    port = mkOption {
      type = types.port;
      default = 41641;
      description = "The port to listen on for tunnel traffic (0=autoselect).";
    };

    interfaceName = mkOption {
      type = types.str;
      default = "tailscale0";
      description = ''The interface name for tunnel traffic. Use "userspace-networking" (beta) to not use TUN.'';
    };

    permitCertUid = mkOption {
      type = types.nullOr types.nonEmptyStr;
      default = null;
      description = "Username or user ID of the user allowed to to fetch Tailscale TLS certificates for the node.";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.tailscale;
      defaultText = literalExpression "pkgs.tailscale";
      description = "The package to use for tailscale";
    };
  };

  config = mkIf cfg.enable {
    warnings = optional (firewallOn && rpfIsStrict) "Strict reverse path filtering breaks Tailscale exit node use and some subnet routing setups. Consider setting `networking.firewall.checkReversePath` = 'loose'";

    environment.systemPackages = [ cfg.package ]; # for the CLI

    systemd.services.tailscaled =
      let
        stateDir =
          if config.modules.eraseDarlings.enable
          then "/persist/var/lib/tailscale"
          else "/var/lib/tailscale";
      in
      {
        description = "Tailscale node agent";

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-pre.target" ];
        after = [
          "network-pre.target"
          "NetworkManager.target"
          "systemd-resolved.target"
        ];

        path = [
          pkgs.openresolv # for configuring DNS in some configs
          pkgs.procps # for collecting running services (opt-in feature)
          pkgs.glibc # for `getent` to look up user shells
        ];

        serviceConfig = {
          Environment = (lib.optionals (cfg.permitCertUid != null) [
            "TS_PERMIT_CERT_UID=${cfg.permitCertUid}"
          ]);

          ExecStartPre = "${cfg.package}/bin/tailscaled --cleanup";
          ExecStart = "${cfg.package}/bin/tailscaled --state ${stateDir}/tailscaled.state --statedir ${stateDir} --socket=/run/tailscale/tailscaled.sock --port ${toString cfg.port} --tun ${lib.escapeShellArg cfg.interfaceName}";
          ExecStopPost = "${cfg.package}/bin/tailscaled --cleanup";

          Restart = "on-failure";

          RuntimeDirectory = "tailscale";
          RuntimeDirectoryMode = 0755;

          CacheDirectory = "tailscale";
          CacheDirectoryMode = 0750;

          Type = "notify";
        };

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
  };
}
