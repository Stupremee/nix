{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.my.amdgpu;
in
{
  options.my.amdgpu = {
    enable = mkEnableOption "AMD GPU support (Mesa radeonsi and RADV Vulkan)";

    compute.enable = mkEnableOption ''
      ROCm compute (HIP and OpenCL) for local AI workloads. Lets the main user open
      /dev/kfd and the render nodes. Verify with `rocminfo` and `clinfo`
    '';
  };

  config = mkIf cfg.enable (mkMerge [
    {
      hardware.graphics.enable = true;

      environment.systemPackages = with pkgs; [
        amdgpu_top
        nvtopPackages.amd
      ];
    }

    (mkIf cfg.compute.enable {
      hardware.amdgpu.opencl.enable = true;

      environment.systemPackages = with pkgs; [
        rocmPackages.rocminfo
        rocmPackages.rocm-smi
        clinfo
      ];

      users.users.${config.my.user.mainUser}.extraGroups = [
        "render"
        "video"
      ];
    })
  ]);
}
