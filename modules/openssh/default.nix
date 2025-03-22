{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.my.openssh;
in
{
  options.my.openssh = {
    enable = mkEnableOption "Enable default settings for openssh";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      startWhenNeeded = true;

      settings = {
        X11Forwarding = false;
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    my.backups.ssh-keys.paths = builtins.map (v: v.path) config.services.openssh.hostKeys;
  };
}
