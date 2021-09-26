{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.services.blocky;

  jsonValue = with types;
    let
      valueType = nullOr
        (oneOf [
          bool
          int
          float
          str
          (lazyAttrsOf valueType)
          (listOf valueType)
        ]) // {
        description = "JSON value";
        emptyValue.value = { };
      };
    in
    valueType;

  configFile = pkgs.runCommand "config.yaml"
    {
      buildInputs = [ pkgs.remarshal ];
      preferLocalBuild = true;
    } ''
    remarshal -if json -of yaml \
      < ${
        pkgs.writeText "dynamic_config.json"
        (builtins.toJSON cfg.options)
      } \
      > $out
  '';
in
{
  options.services.blocky = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the Blocky DNS server";
    };

    package = mkOption {
      default = pkgs.blocky;
      type = types.package;
    };

    options = mkOption {
      type = jsonValue;
      default = null;
    };

    group = mkOption {
      default = "blocky";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.blocky = {
      description = "Blocky DNS server";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      startLimitIntervalSec = 86400;
      startLimitBurst = 5;
      serviceConfig = {
        ExecStart =
          "${cfg.package}/bin/blocky --config=${configFile}";
        Type = "simple";
        User = "blocky";
        Group = cfg.group;
        Restart = "on-failure";
        AmbientCapabilities = "cap_net_bind_service";
        CapabilityBoundingSet = "cap_net_bind_service";
        NoNewPrivileges = true;
        LimitNPROC = 64;
        LimitNOFILE = 1048576;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHome = true;
        ProtectSystem = "full";
      };
    };

    users.users.blocky = {
      group = "blocky";
      createHome = false;
      isSystemUser = true;
    };

    users.groups.blocky = { };
  };
}
