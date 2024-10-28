{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.my.docker;
in {
  options.my.docker = {
    enable = mkEnableOption "Enable docker containers";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [docker-compose];

    virtualisation.docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    virtualisation.oci-containers = {
      backend = "docker";
    };

    users.extraUsers.${config.my.user.mainUser}.extraGroups = ["docker"];
  };
}
