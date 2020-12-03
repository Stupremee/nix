{ pkgs, ... }: {
  imports = [ ./hardened.nix ./nix.nix ];

  i18n = { defaultLocale = "en_US.UTF-8"; };

  time.timeZone = "Europe/Berlin";

  fonts.fonts = with pkgs; [
    fira-code
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

  environment.variables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_BIN_HOME = "$HOME/.local/bin";
  };
}
