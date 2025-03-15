{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.my.mako;
in
{
  options.my.mako = {
    enable = mkEnableOption "Enable mako notification daemon";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.libnotify ];

    services.mako = {
      enable = true;
    };
  };
}
