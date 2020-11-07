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
    my.zsh.env = ''
      export DDLOG_HOME=${pkgs.my.ddlog}
      export PATH="$PATH:${pkgs.my.ddlog}/bin"
    '';
  };
}
