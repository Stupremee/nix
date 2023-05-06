{...}: {
  # Enable caddy web server
  services.caddy = {
    enable = true;
    email = "justus.k@protonmail.com";
  };

  services.caddy.virtualHosts."ironite.neon-opah.ts.net".extraConfig = ''
    forward_auth unix//run/tailscale/nginx-auth.sock {
    	uri /auth
    	header_up Remote-Addr {remote_host}
    	header_up Remote-Port {remote_port}
    	header_up Original-URI {uri}
    }
  '';
}
