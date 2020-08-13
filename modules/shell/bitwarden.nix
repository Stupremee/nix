{ config, options, pkgs, lib, ... }:
with lib;
{
  options.modules.shell.bitwarden = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.shell.bitwarden.enable {
    my = {
      packages = with pkgs; [
        bitwarden-cli
        jq
      ];
    };
  };
}
