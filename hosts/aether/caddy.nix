{ config, ... }:
let
  inherit (builtins) toString;

  cfg = config.services.caddy;

  vaultwarden = config.services.vaultwarden.config;
  paperless = config.services.paperless-ng;

  secret = path: {
    file = path;
    owner = cfg.user;
    group = cfg.group;
    mode = "0440";
  };
in
{
  # Import certificates
  age.secrets."cert/stu-dev.me.key" = secret ../../secrets/cert/stu-dev.me.key;
  age.secrets."cert/stu-dev.me.pem" = secret ../../secrets/cert/stu-dev.me.pem;
  age.secrets."cert/stx.li.key" = secret ../../secrets/cert/stx.li.key;
  age.secrets."cert/stx.li.pem" = secret ../../secrets/cert/stx.li.pem;

  services.caddy =
  let
    common = ''
      encode gzip zstd
      log
    '';

    tls = url: ''
      tls ${config.age.secrets."cert/${url}.pem".path} ${config.age.secrets."cert/${url}.key".path}
    '';
  in {
    enable = true;

    config = ''
      bw.stu-dev.me {
        ${common}
        ${tls "stu-dev.me"}
        reverse_proxy ${vaultwarden.rocketAddress}:${toString vaultwarden.rocketPort}
      }

      d.stx.li {
        ${common}
        ${tls "stx.li"}
        reverse_proxy ${paperless.address}:${toString paperless.port}
      }
    '';
  };

  # Open firewall for Caddy HTTPS port
  networking.firewall.allowedTCPPorts = [ 443 ];

  # Make dataDir persistent
  environment.persist.directories = [
    cfg.dataDir
  ];
}
