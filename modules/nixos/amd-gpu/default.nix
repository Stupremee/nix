{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.amdgpu;
in
{
  options.my.amdgpu = {
    enable = mkEnableOption "Enable AMD GPU settings";
  };

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = [ "amdgpu" ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.amdgpu = {
      initrd.enable = true;
      amdvlk.enable = true;
    };
  };
}
