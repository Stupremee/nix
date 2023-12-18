{
  pkgs,
  unstable-pkgs,
  ...
}: {
  fonts = {
    packages = let
      nerdFont = unstable-pkgs.nerdfonts.override {
        fonts = ["Monaspace" "Noto"];
      };
    in
      with pkgs; [
        nerdFont
        monaspace
        noto-fonts
        noto-fonts-color-emoji
      ];

    enableDefaultPackages = false;

    fontconfig.defaultFonts = {
      serif = ["NotoSerif Nerd Font" "Noto Serif"];
      sansSerif = ["NotoSans Nerd Font" "Noto Sans"];
      monospace = ["MonaspiceNe Nerd Font Mono" "Monaspace Neon"];
      emoji = ["Noto Color Emoji"];
    };
  };
}
