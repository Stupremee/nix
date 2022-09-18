{ pkgs, ... }: {
  programs.gpg = {
    enable = true;
  };

  home.packages = with pkgs; [ pinentry-qt ];
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    sshKeys = [ "5AB7076AF80B4337FB20968CD54A1CD51376F46C" ];
    pinentryFlavor = "qt";
  };
}
