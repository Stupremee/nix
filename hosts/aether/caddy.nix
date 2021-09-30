{ config, ... }:
let
  cfg = config.services.caddy;

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

    config = '''';
  };

  # Open firewall for Caddy HTTPS port
  networking.firewall.allowedTCPPorts = [ 443 ];

  # Make dataDir persistent
  environment.persist.directories = [
    cfg.dataDir
  ];
}
