{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.my.yubikey;
in {
  options.my.yubikey = {
    enable = mkEnableOption "Enable yubikey support";
  };

  config = mkIf cfg.enable {
    programs.ssh.startAgent = false;

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    environment.shellInit = ''
      export GPG_TTY="$(tty)"
      gpg-connect-agent /bye
      export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
    '';

    services.pcscd.enable = true;

    environment.systemPackages = [pkgs.yubikey-personalization];
    services.udev.packages = [pkgs.yubikey-personalization];
  };
}
