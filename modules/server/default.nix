{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.my.server;
in
{
  options.my.server = {
    enable = mkEnableOption "Enable the default server configuration";
  };

  config = mkIf cfg.enable {
    my = {
      user = {
        root.enable = true;
        stu.enable = true;
      };

      docker.enable = true;

      networking = {
        enable = true;
        tailscale = {
          enable = true;
          profile = mkDefault "server";
          openFirewall = mkDefault true;
        };
      };

      nix-common.enable = true;
      openssh.enable = true;
      zsh.enable = true;
      backup.enable = true;
    };

    environment.enableAllTerminfo = true;

    programs.dconf.enable = true;
    powerManagement.cpuFreqGovernor = "powersave";
  };
}
