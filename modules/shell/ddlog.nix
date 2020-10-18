{ config, options, pkgs, lib, ... }:
with lib;
{
  options.modules.shell.ddlog = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.shell.ddlog.enable {
    my.packages = with pkgs; [ my.ddlog ];
  };
}
