{ pkgs, lib, config, ... }:
let cfg = config.my.services.tailscale;
in
with lib; {
  options.my.services.tailscale = {
    enable = mkEnableOption "Enables Tailscale";

    port = mkOption {
      type = types.port;
      default = 41641;
      description = "The port to listen on for tunnel traffic (0=autoselect).";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.tailscale;
      defaultText = "pkgs.tailscale";
      description = "The package to use for tailscale";
    };

    autoprovision = {
      enable = mkEnableOption "Automatically provision this with an API key?";

      keyFile = mkOption {
        type = types.str;
        description = "The API secret file used to provision Tailscale access";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ tailscale ];

    systemd.packages = [ cfg.package ];

    systemd.services.tailscale = {
      description = "Tailscale client daemon";

      after = [ "network.target" ];
      wants = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      unitConfig = {
        StartLimitIntervalSec = 0;
        StartLimitBurst = 0;
      };

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/tailscaled --port ${toString cfg.port}";

        RuntimeDirectory = "tailscale";
        RuntimeDirectoryMode = 755;

        StateDirectory = "tailscale";
        StateDirectoryMode = 750;

        CacheDirectory = "tailscale";
        CacheDirectoryMode = 750;

        Restart = "on-failure";
      };
    };

    systemd.services.tailscale-autoprovision = mkIf cfg.autoprovision.enable {
      description = "Automatic connection to Tailscale";

      after = [ "network.target" "tailscale.service" ];
      wants = [ "network.target" "tailscale.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RuntimeDirectory = "tailscale";
        RuntimeDirectoryMode = 755;

        StateDirectory = "tailscale";
        StateDirectoryMode = 750;

        CacheDirectory = "tailscale";
        CacheDirectoryMode = 750;
      };

      script = ''
        sleep 2
        ${cfg.package}/bin/tailscale down
        sleep 2
        ${cfg.package}/bin/tailscale up --authkey=`cat ${cfg.autoprovision.keyFile}`
      '';
    };
  };
}
