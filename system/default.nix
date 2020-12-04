{ pkgs, ... }: {
  imports = [ ./hardened.nix ./nix.nix ];

  i18n = { defaultLocale = "en_US.UTF-8"; };

  time.timeZone = "Europe/Berlin";

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "Hack" ]; })
    noto-fonts-emoji
  ];

  fonts.fontconfig.defaultFonts = {
    serif = [ "Noto Serif Nerd Font" ];
    sansSerif = [ "Noto Sans Nerd Font" ];
    monospace = [ "FiraCode Nerd Font" ];
    emoji = [ "Noto Color Emoji" ];
  };

  environment.variables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_BIN_HOME = "$HOME/.local/bin";
  };
}
