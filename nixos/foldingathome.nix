{...}: {
  services.caddy.virtualHosts."ironite.neon-opah.ts.net".extraConfig = ''
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
