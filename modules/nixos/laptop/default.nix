{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.laptop;
in
{
  options.my.laptop = {
    enable = mkEnableOption "Enable Laptop specific configuration";
  };

  config = mkIf cfg.enable {
    services.upower.enable = true;

    powerManagement.cpuFreqGovernor = "powersave";
  };
}
