{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.my.cloudflare-tunnel;
  tunnelId = "f3bb1152-ff1c-473f-bb1a-221591433d87";
in
{
  options.my.cloudflare-tunnel.enable = mkEnableOption "Enable Rome's Cloudflare tunnel";

  config = mkIf cfg.enable {
    age.secrets.cloudflare-tunnel-rome.rekeyFile = ../../../secrets/rome-cloudflare-tunnel.age;

    services.cloudflared = {
      enable = true;
      tunnels.${tunnelId} = {
        credentialsFile = config.age.secrets.cloudflare-tunnel-rome.path;
        ingress = {
          "cliproxy.stu-dev.me" = "http://127.0.0.1:8318";
          "cliproxy-admin.stu-dev.me" = "http://127.0.0.1:8319";
        };
        default = "http_status:404";
      };
    };
  };
}
