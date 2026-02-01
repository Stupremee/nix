{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.my.stremio;
in
{
  options.my.stremio = {
    enable = mkEnableOption "Enable Stremio server";

    domain = mkOption {
      type = types.str;
      default = "stremio.stu-dev.me";
      description = "Domain for the Stremio server";
    };

    httpPort = mkOption {
      type = types.port;
      default = 11470;
      description = "HTTP port for Stremio server";
    };

    httpsPort = mkOption {
      type = types.port;
      default = 12470;
      description = "HTTPS/streaming port for Stremio server";
    };
  };

  config = mkIf cfg.enable {
    # Ensure docker is enabled
    my.docker.enable = true;

    # Stremio server container
    virtualisation.oci-containers.containers.stremio = {
      image = "stremio/server:latest";
      ports = [
        "${toString cfg.httpPort}:11470"
        "${toString cfg.httpsPort}:12470"
      ];
      environment = {
        NO_CORS = "1";
      };
      extraOptions = [ "--pull=always" ];
    };

    # Caddy reverse proxy for HTTP port
    services.caddy.virtualHosts.${cfg.domain}.extraConfig = ''
      import cloudflare
      reverse_proxy :${toString cfg.httpPort}
    '';
  };
}
