{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.my.bluetooth;
in
{
  options.my.bluetooth = {
    enable = mkEnableOption "Enable bluetooth";
  };

  config = mkIf cfg.enable {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
  };
}
