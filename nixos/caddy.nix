{config, ...}: {
  # Enable caddy web server
  services.caddy = {
    enable = true;
    email = "justus.k@protonmail.com";
    logFormat = ''
      level WARN
    '';
  };

  services.tailscale = {
    permitCertUid = config.services.caddy.user;
  };
}
