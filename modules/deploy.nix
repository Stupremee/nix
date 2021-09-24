{ config, options, lib, ... }:
with lib;
let
  cfg = config.deploy;
in
{
  options.deploy = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable remote deployment for this host";
    };

    ip = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Overwrite the IP to use for connecting via SSH.";
    };
  };

  config = { };
}
