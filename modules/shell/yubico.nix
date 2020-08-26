{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.shell.yubico = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.shell.yubico.enable {
    my.packages = with pkgs; [
      gnupg
      yubikey-personalization
    ];

    services.udev.packages = with pkgs; [
      yubikey-personalization
    ];
    services.udev = {
      extraRules = ''
        SUBSYSTEM=="usb", ATTR{idProduct}=="7321", ATTR{idVendor}=="0955", MODE="0777"
      '';
    };

    services.pcscd.enable = true;
    programs.ssh.startAgent = false;

    my.zsh.rc = ''
      gpg-connect-agent /bye
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    '';
  };
}
