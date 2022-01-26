{ config, ... }:
let
  inherit (builtins) toString;

  cfg = config.services.nginx;

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

  services.nginx = {
    enable = true;

    # Use recommended settings
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

    commonHttpConfig = ''
      # Add HSTS header with preloading to HTTPS requests.
      # Adding this header to HTTP requests is discouraged
      map $scheme $hsts_header {
          https   "max-age=31536000; includeSubdomains; preload";
      }
      add_header Strict-Transport-Security $hsts_header;

      # Enable CSP for your services.
      #add_header Content-Security-Policy "script-src 'self'; object-src 'none'; base-uri 'none';" always;

      # Minimize information leaked to other domains
      add_header 'Referrer-Policy' 'origin-when-cross-origin';

      # Disable embedding as a frame
      # add_header X-Frame-Options DENY;

      # Prevent injection of code in other mime types (XSS Attacks)
      add_header X-Content-Type-Options nosniff;

      # Enable XSS protection of the browser.
      # May be unnecessary when CSP is configured properly (see above)
      add_header X-XSS-Protection "1; mode=block";

      # This might create errors
      proxy_cookie_path / "/; secure; HttpOnly; SameSite=strict";
    '';

    virtualHosts =
      let
        base = cert: locations: {
          inherit locations;

          onlySSL = true;

          sslCertificate = config.age.secrets."cert/${cert}.pem".path;
          sslCertificateKey = config.age.secrets."cert/${cert}.key".path;
        };

        proxy = cert: port: base cert {
          "/".proxyPass = "http://127.0.0.1:" + toString (port) + "/";
        };
      in
      {
        "stu-dev.me" = (base "stu-dev.me" { }) // {
          extraConfig = "return 404;";
          default = true;
        };

        "bw.stu-dev.me" = proxy "stu-dev.me" vaultwarden.rocketPort;
        "t.stu-dev.me" = proxy "stu-dev.me" 22000;

        "stx.li" = (base "stx.li" { }) // {
          extraConfig = "return 404;";
        };
        "g.stx.li" = proxy "stx.li" 22001;
        #"a.stx.li" = proxy "stx.li" 8089;
      };
  };

  # Open firewall for Nginx HTTPS port
  networking.firewall.allowedTCPPorts = [ 443 ];
}