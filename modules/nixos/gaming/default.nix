{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.gaming;
in
{
  options.my.gaming = {
    steam.enable = mkEnableOption "Enables Steam";
  };

  config = mkIf cfg.steam.enable {
    programs.steam = {
      enable = true;
      protontricks.enable = true;
    };
  };
}
