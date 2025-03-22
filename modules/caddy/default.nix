{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.my.caddy;
in
{
  options.my.caddy = {
    enable = mkEnableOption "Enable caddy reverse proxy";
  };

  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
      email = "justus.k@protonmail.com";
      logFormat = ''
        level WARN
      '';

      extraConfig = ''
        (cloudflare) {
          tls {
            dns cloudflare {env.CLOUDFLARE_API_TOKEN}
            resolvers 1.1.1.1 1.0.0.1
          }
        }
      '';
    };

    my.persist.directories = [ "/var/lib/caddy" ];

    age.secrets.caddyEnv.rekeyFile = ../../secrets/caddy.env.age;
    systemd.services.caddy.serviceConfig = {
      EnvironmentFile = config.age.secrets.caddyEnv.path;
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
    };
  };
}
