{ config, options, pkgs, lib, ... }:
with lib;
{
  options.modules.services.lorri = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.services.lorri.enable {
    my = {
      packages = with pkgs; [ direnv ];

      zsh.rc = '' eval "$(direnv hook zsh)" '';
    };

    services.lorri.enable = true;
  };
}
