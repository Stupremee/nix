# GPG and SSH configurations

{ ... }: {
  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    sshKeys = [ "5AB7076AF80B4337FB20968CD54A1CD51376F46C" ];
    pinentryFlavor = "gnome3";
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
      Host x
          User arc
          HostName 207.180.210.181
    '';
  };

}
