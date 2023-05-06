{...}: {
  services.caddy.virtualHosts."ironite.neon-opah.ts.net".extraConfig = ''
    forward_auth unix//run/tailscale/nginx-auth.sock {
    	uri /auth
    	header_up Remote-Addr {remote_host}
    	header_up Remote-Port {remote_port}
    	header_up Original-URI {uri}
    }

    reverse_proxy :7396
  '';

  services.foldingathome = {
    enable = true;
    user = "ironite";
    daemonNiceLevel = 10;
    extraArgs = ["--cpus=12"];
  };

  boot.kernel.sysctl = {
    "kernel.unprivileged_userns_clone" = 1;
  };
}
