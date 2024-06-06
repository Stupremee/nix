{
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs) stdenv;
in {
  programs.gpg = {
    enable = true;
  };

  home.packages = lib.optionals stdenv.isLinux (with pkgs; [pinentry-qt]);
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    sshKeys = ["5AB7076AF80B4337FB20968CD54A1CD51376F46C"];
    pinentryPackage =
      if stdenv.isDarwin
      then pkgs.pinentry_max
      else pkgs.pinentry.qt;
  };
}
