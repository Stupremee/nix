{unstable-pkgs, ...}: {
  modules.hyprland = {
    enable = true;

    sensitivity = "0.0";

    monitors = {
      "DP-1" = {
        position = "0x0";
        resolution = "2560x1440@144";
      };
    };
  };

  home.packages = with unstable-pkgs; [
    prismlauncher
  ];
}
