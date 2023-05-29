{pkgs, ...}: {
  fonts = {
    fonts = with pkgs; [
      (nerdfonts.override {fonts = ["FiraCode" "Noto"];})
      noto-fonts
      noto-fonts-emoji
      fira-code

      material-icons
      material-design-icons
    ];

    enableDefaultFonts = false;

    fontconfig.defaultFonts = {
      serif = ["NotoSerif Nerd Font" "Noto Serif"];
      sansSerif = ["NotoSans Nerd Font" "Noto Sans"];
      monospace = ["FiraCode Nerd Font" "Fira Code"];
      emoji = ["Noto Color Emoji"];
    };
  };
}
