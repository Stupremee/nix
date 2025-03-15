{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.my.locale;
in
{
  options.my.locale = {
    enable = mkEnableOption "Set default locale settings";
  };

  config = mkIf cfg.enable {
    time = {
      timeZone = "Europe/Berlin";
      hardwareClockInLocalTime = true;
    };

    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };

    console = {
      earlySetup = true;
      packages = [ pkgs.terminus_font ];
      font = "${pkgs.terminus_font}/share/consolefonts/ter-112n.psf.gz";
      keyMap = "us";
    };
  };
}
