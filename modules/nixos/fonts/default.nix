{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.my.fonts;
in
{
  options.my.fonts = {
    enable = mkEnableOption "Enable default fonts";
  };

  config = mkIf cfg.enable {
    fonts = {
      fontDir.enable = true;

      packages = with pkgs; [
        nerd-fonts.monaspace
        nerd-fonts.noto

        monaspace
        noto-fonts
        noto-fonts-color-emoji
        corefonts
      ];

      enableDefaultPackages = false;

      fontconfig.defaultFonts = {
        serif = [
          "NotoSerif Nerd Font"
          "Noto Serif"
        ];
        sansSerif = [
          "NotoSans Nerd Font"
          "Noto Sans"
        ];
        monospace = [
          "MonaspiceNe Nerd Font Mono"
          "Monaspace Neon"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
