{ config, ... }:
let
  secret = path: {
    file = path;
    group = config.services.traefik.group;
    mode = "0440";
  };
in
{
  # Import certificates
  age.secrets."cert/stu-dev.me.key" = secret ../../secrets/cert/stu-dev.me.key;
  age.secrets."cert/stu-dev.me.pem" = secret ../../secrets/cert/stu-dev.me.pem;

  age.secrets."cert/stx.li.key" = secret ../../secrets/cert/stx.li.key;
  age.secrets."cert/stx.li.pem" = secret ../../secrets/cert/stx.li.pem;

  services.traefik = {
    enable = true;

    staticConfigOptions = {
      entryPoints.web.address = ":80";
      entryPoints.websecure.address = ":443";

      api.dashboard = true;
    };

    dynamicConfigOptions = {
      http.routers = {
        api = {
          entrypoints = [ "web" ];
          middlewares = [ "privateService" ];
          service = "api@internal";
          rule = "Path(`/traefik`)";
        };
      };

      http.middlewares = {
        privateService.ipwhitelist.sourcerange = "127.0.0.1/32, 100.100.241.20/32";
      };

      # Use TLS certificates
      tls.certificates = [
        {
          certFile = config.age.secrets."cert/stu-dev.me.pem".path;
          keyFile = config.age.secrets."cert/stu-dev.me.key".path;
        }
        {
          certFile = config.age.secrets."cert/stx.li.pem".path;
          keyFile = config.age.secrets."cert/stx.li.key".path;
        }
      ];
    };
  };

  # Open firewall for Traefik
  networking.firewall.allowedTCPPorts = [ 443 ];

  # Make dataDir persistent
  environment.persist.directories = [
    "/var/lib/traefik"
  ];
}
