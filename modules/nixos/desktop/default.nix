{
  lib,
  config,
  pkgs,
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
    environment.systemPackages = with pkgs; [
      # TUI for configuration IWD
      impala
    ];

    my = {
      user = {
        stu = {
          enable = true;
          enableHome = true;
        };
        root.enable = true;
      };

      wayland = {
        enable = true;
      };

      docker.enable = true;
      fonts.enable = true;
      sound.enable = true;
      locale.enable = true;
      avahi.enable = true;

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

    environment.enableAllTerminfo = true;

    programs = {
      dconf.enable = true;
      _1password.enable = true;
      nm-applet.enable = true;
    };

    powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  };
}
