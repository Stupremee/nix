{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.my.server;
in {
  options.my.server = {
    enable = mkEnableOption "Enable the default server configuration";
  };

  config = mkIf cfg.enable {
    imports = [
      inputs.srvos.nixosModules.server
    ];

    my = {
      user = {
        root.enable = true;
        mainUser = "root";
      };

      docker.enable = true;
      fonts.enable = true;

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
      zsh.enable = true;
    };

    programs.dconf.enable = true;
    powerManagement.cpuFreqGovernor = "powersave";
  };
}
