{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.my.protonmail-bridge;
  user = config.my.user.mainUser;
in
{
  options.my.protonmail-bridge = {
    enable = mkEnableOption "Proton Mail Bridge as a headless user service of the main user";
  };

  # Bridge listens on loopback only: IMAP 127.0.0.1:1143 (STARTTLS), SMTP 127.0.0.1:1025.
  # State lives in the user's home (~/.config/protonmail, ~/.local/share/protonmail).
  config = mkIf cfg.enable {
    services.protonmail-bridge = {
      enable = true;
      # Bridge keeps its vault key in `pass`, which must be initialised for the user.
      path = with pkgs; [
        pass
        gnupg
      ];
    };

    systemd.user.services.protonmail-bridge = {
      # The upstream unit hangs off graphical-session.target, which never starts headless.
      wantedBy = mkForce [ "default.target" ];
      after = mkForce [ ];
      # User units exist for every user; other logins (e.g. the scanner's SSH user) must not
      # start a second Bridge.
      unitConfig.ConditionUser = user;
    };

    # Starts the user manager at boot, without a login.
    users.users.${user}.linger = true;
  };
}
