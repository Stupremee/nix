## Reusable module for configuring NVIDIA GPUs.
##
## Can be used on both X11 and Wayland.
{
  config,
  pkgs,
  ...
}: {
  # Make sure nouveau never runs alongside the official driver.
  boot.blacklistedKernelModules = ["nouveau"];

  # Configure the video driver to use on Wayland and X11.
  services.xserver.videoDrivers = ["nvidia"];

  # Enable Vulkan support.
  environment.systemPackages = with pkgs; [
    # vulkan-loader
    # vulkan-validation-layers
    vulkan-tools
  ];

  # Recommended environment variables for enhanced experience.
  environment.sessionVariables = {
    VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NVD_BACKEND = "direct";
  };

  # Hardware configuration for NVIDIA GPUs.
  hardware = {
    opengl = {
      enable = true;
      driSupport32Bit = true;

      # extraPackages = with pkgs; [nvidia-vaapi-driver];
    };

    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      powerManagement.enable = false;
      modesetting.enable = true;
      open = false;
    };
  };
}
