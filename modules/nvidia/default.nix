{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.my.nvidia;
in {
  options.my.nvidia = {
    enable = mkEnableOption "Enable nvidia support";
  };

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = ["nvidia"];

    # Make sure nouveau never runs alongside the official driver.
    boot.blacklistedKernelModules = ["nouveau"];

    hardware = {
      opengl = {
        enable = true;
        driSupport32Bit = true;
      };

      nvidia = {
        open = true;
        modesetting.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [nvtopPackages.full];
  };
}
