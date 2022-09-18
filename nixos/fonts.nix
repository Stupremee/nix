{ pkgs, ... }: {
  fonts = {
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "Noto" ]; })
      noto-fonts
      noto-fonts-emoji
      fira-code
    ];

    fontconfig.defaultFonts = {
      serif = [ "Noto Serif Nerd Font" "Noto Serif" ];
      sansSerif = [ "NotoSans Nerd Font" "Noto Sans" ];
      monospace = [ "Fira Code Nerd Font" "Fira Code Font" ];
      emoji = [ "Noto  Color Emoji" ];
    };
  };
}
