{ inputs, system, ... }:
let
  hyprland = inputs.hyprland.packages."${system}".default.override {
    enableXWayland = true;
    nvidiaPatches = true;
  };
in {
  wayland.windowManager.hyprland = {
    enable = true;
    package = hyprland;

    systemdIntegration = true;

    xwayland.enable = true;
    xwayland.hidpi = true;

    recommendedEnvironment = true;

    extraConfig = ''
      bind=SUPER,Return,exec,$TERMINAL
    '';
  };

  programs.zsh.loginExtra = ''
    [ "$(tty)" = "/dev/tty1" ] && exec "${hyprland}/bin/Hyprland"
  '';

  home.sessionVariables = {
    # LIBVA_DRIVER_NAME = "nvidia";
    # GBM_BACKEND = "nvidia-drm";
    # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # WLR_NO_HARDWARE_CURSORS = "1";
  };
}
