{ config, lib, pkgs, ... }:
{
  my.packages = with pkgs; [
    zathura
    feh
    mpv
    xclip
    xdotool
  ];

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      ubuntu_font_family
      dejavu_fonts
      fira-code
      fira-code-symbols
      symbola
      noto-fonts
      noto-fonts-cjk
      font-awesome-ttf
      siji
      hack-font
    ];
    fontconfig.defaultFonts = {
      sansSerif = ["Ubuntu"];
      monospace = ["Hack"];
    };
  };

  services.xserver = {
    displayManager.lightdm.greeters.mini.user = config.my.username;
    xkbOptions = "caps:swapescape";
    videoDrivers = [ "nvidia" ];
  };

  services.picom = {
    backend = "glx";
    vSync = true;
    opacityRules = [
      "90:class_g = 'Discord'"
    ];
    shadowExclude = [
      "! name~='(rofi|scratch|Dunst)$'"
    ];
    settings.blur-background-exclude = [
      "window_type = 'dock'"
      "window_type = 'desktop'"
      "class_g = 'Rofi'"
      "_GTK_FRAME_EXTENTS@:c"
    ];
  };
}
