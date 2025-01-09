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
      graphics = {
        enable = true;
        enable32Bit = true;

        extraPackages = with pkgs; [
          nvidia-vaapi-driver
        ];
      };

      nvidia = {
        open = false;
        modesetting.enable = true;
      };
    };

    environment = {
      systemPackages = with pkgs; [nvtopPackages.full];

      sessionVariables = {
        LIBVA_DRIVER_NAME = "nvidia";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        NVD_BACKEND = "direct";
      };
    };
  };
}
