{ pkgs, config, lib, ... }: {
  programs.gpg.enable = true;

  home.packages = with pkgs; [ pinentry-qt ];
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    sshKeys = [ "5AB7076AF80B4337FB20968CD54A1CD51376F46C" ];
    pinentryFlavor = "qt";
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host gh
          User git
          HostName github.com
      Host github
          User git
          HostName github.com
    '';
  };
}
