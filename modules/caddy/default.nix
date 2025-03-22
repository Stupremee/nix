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

      globalConfig = ''
        acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      '';
    };

    age.secrets.caddyEnv.rekeyFile = ../../secrets/caddy.env.age;
    systemd.services.caddy.serviceConfig.EnvironmentFile = config.age.secrets.caddyEnv.path;
  };
}
