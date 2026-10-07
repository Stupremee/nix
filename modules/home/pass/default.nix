{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.my.pass;
in
{
  options.my.pass.enable = mkEnableOption "pass, the standard unix password manager, with a GPG agent";

  config = mkIf cfg.enable {
    programs.password-store = {
      enable = true;
      settings.PASSWORD_STORE_DIR = "${config.xdg.dataHome}/password-store";
    };

    programs.gpg.enable = true;

    # Hosts using this are reached over SSH, so prompt for the passphrase in the terminal.
    services.gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-curses;
    };
  };
}
