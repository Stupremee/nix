{ config, ... }:
let
  inherit (builtins) toString;

  cfg = config.services.caddy;

  vaultwarden = config.services.vaultwarden.config;

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

  services.caddy = {
    enable = true;

    config = ''
      bw.stu-dev.me {
        encode gzip zstd
        log
        tls ${config.age.secrets."cert/stu-dev.me.pem".path} ${config.age.secrets."cert/stu-dev.me.key".path}
        reverse_proxy ${vaultwarden.rocketAddress}:${toString vaultwarden.rocketPort}
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
