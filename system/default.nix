{ pkgs, ... }: {
  imports = [ ./hardened.nix ./nix.nix ];

  i18n = { defaultLocale = "en_US.UTF-8"; };

  time.timeZone = "Europe/Berlin";

  fonts.fonts = with pkgs; [
    fira-code
    hack-font
    noto-fonts
    noto-fonts-extra
    noto-fonts-cjk
    noto-fonts-emoji
  ];

  fonts.fontconfig.defaultFonts = {
    serif = [ "Noto Serif" "Noto Color Emoji" ];
    sansSerif = [ "Noto Sans" "Noto Color Emoji" ];
    monospace = [ "Fira Code" "Noto Color Emoji" ];
    emoji = [ "Noto Color Emoji" ];
  };
}
