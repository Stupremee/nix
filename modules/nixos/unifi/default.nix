{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.my.unifi;
in
{
  options.my.unifi = {
    enable = mkEnableOption "Enable the Unifi controller software";
  };

  config = mkIf cfg.enable {
    services.unifi = {
      enable = true;
      openFirewall = true;
    };
  };
}
