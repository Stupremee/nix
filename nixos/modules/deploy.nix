{ config, lib, ... }:
with lib;
let
  cfg = config.modules.deploy;
in
{
  options = {
    modules.deploy = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      ip = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Overwrite the IP to use for connecting via SSH.";
      };
    };
  };

  config = { };
}
