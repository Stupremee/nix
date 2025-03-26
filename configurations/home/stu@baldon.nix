{ pkgs, ... }:
{
  home.packages = with pkgs; [
    firefox-devedition
    ungoogled-chromium
    teams-for-linux
  ];

  my = {
    hyprland = {
      sensitivity = "-0.5";
      monitors = {
        "DP-5" = {
          position = "0x0";
          resolution = "3840x2160@60";
          scale = "1.5";
        };

        "DP-3" = {
          position = "2560x0";
          resolution = "3840x2160@60";
          scale = "1.5";
        };

        "Unknown-1".disable = true;
      };
    };
  };
}
