{
  config,
  pkgs,
  ...
}: {
  services.xserver.videoDrivers = ["amdgpu"];

  # Hardware configuration for NVIDIA GPUs.
  hardware = {
    opengl = {
      enable = true;
      driSupport32Bit = true;

      extraPackages = with pkgs; [amdvlk];
      extraPackages32 = with pkgs; [driversi686Linux.amdvlk];
    };
  };

  # Install LACT
  environment.systemPackages = with pkgs; [lact];
  systemd.packages = with pkgs; [lact];
  systemd.services.lactd = {
    enable = true;
    wantedBy = ["multi-user.target"];
  };
}
