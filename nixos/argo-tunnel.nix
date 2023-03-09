{
  pkgs,
  unstable-pkgs,
  config,
  ...
}: let
  argoConfig = pkgs.writeText "argo-tunnel.yaml" ''
    tunnel: ironite
    credentials-file: ${config.age.secrets.argotunnel.path}

    loglevel: warn

    ingress:
      - hostname: iron.stu-dev.me
        service: http://localhost:4430
      - service: http_status:404
  '';
in {
  age.secrets.argotunnel = {
    file = ../secrets/argotunnel.json;
    owner = "argo";
    group = "argo";
  };

  users = {
    groups.argo.name = "argo";

    users = {
      argo = {
        home = "/var/lib/argo";
        createHome = true;
        isSystemUser = true;
        group = "argo";
      };
    };
  };

  boot.kernel.sysctl = {
    "net.core.rmem_max" = 2500000;
  };

  systemd.services.argotunnel = {
    description = "Cloudflare Argo Tunnel";
    after = ["network-online.target"];
    wants = ["network-online.target"]; # systemd-networkd-wait-online.service
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "${unstable-pkgs.cloudflared}/bin/cloudflared --config ${argoConfig} --no-autoupdate tunnel run";
      Type = "simple";
      User = "argo";
      Group = "argo";
      Restart = "on-failure";
      RestartSec = "5s";
      NoNewPrivileges = true;
      LimitNPROC = 512;
      LimitNOFILE = 1048576;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectHome = true;
      ProtectSystem = "full";
      ReadWriteDirectories = "/var/lib/argo";
    };
  };
}
