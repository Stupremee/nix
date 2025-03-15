{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.my.desktop;
in
{
  options.my.desktop = {
    enable = mkEnableOption "Enable the default desktop configuration";
  };

  config = mkIf cfg.enable {
    my = {
      user = {
        stu.enable = true;
        root.enable = true;
      };

      wayland = {
        enable = true;
      };

      docker.enable = true;
      fonts.enable = true;
      sound.enable = true;
      locale.enable = true;

      networking = {
        enable = true;
        tailscale = {
          enable = true;
          profile = mkDefault "client";
          openFirewall = mkDefault true;
        };
      };

      nix-common.enable = true;
      openssh.enable = true;
      yubikey.enable = true;
      zsh.enable = true;
    };

    programs.dconf.enable = true;

    powerManagement.cpuFreqGovernor = "performance";
  };
}
