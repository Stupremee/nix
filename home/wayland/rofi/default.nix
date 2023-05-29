{
  pkgs,
  theme,
  ...
}: {
  home.packages = [pkgs.rofi-wayland];

  xdg.configFile."rofi/config/askpass.rasi".source = ./config/askpass.rasi;
  xdg.configFile."rofi/config/confirm.rasi".source = ./config/confirm.rasi;
  xdg.configFile."rofi/config/font.rasi".source = ./config/font.rasi;
  xdg.configFile."rofi/config/launcher.rasi".source = ./config/launcher.rasi;
  xdg.configFile."rofi/config/powermenu.rasi".source = ./config/powermenu.rasi;
  xdg.configFile."rofi/config/runner.rasi".source = ./config/runner.rasi;
  xdg.configFile."rofi/config/screenshot.rasi".source = ./config/screenshot.rasi;

  xdg.configFile."rofi/config/colors.rasi".text = ''
    * {
        BG:    ${theme.base}ff;
        BGA:   ${theme.sky}ff;
        FG:    ${theme.text}ff;
        FGA:   ${theme.red}ff;
        BDR:   ${theme.sapphire}ff;
        SEL:   ${theme.base}ff;
        UGT:   ${theme.red}ff;
        IMG:   ${theme.yellow}ff;
        OFF:   ${theme.overlay0}ff;
        ON:    ${theme.green}ff;
    }
  '';

  xdg.configFile."rofi/bin".source = ./bin;
}
