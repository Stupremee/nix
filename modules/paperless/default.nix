{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.my.paperless;
in
{
  options.my.paperless = {
    enable = mkEnableOption "Enable paperless-ngx";
  };

  config = mkIf cfg.enable {

  };
}
