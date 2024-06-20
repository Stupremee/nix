{config, ...}: {
  age.secrets.grafanaAdminPassword = {
    owner = "grafana";
    group = "grafana";
    file = ../../secrets/password/grafana-admin;
  };

  age.secrets.grafanaSmtpPassword = {
    owner = "grafana";
    group = "grafana";
    file = ../../secrets/password/monitoring-at-stu-dev.me;
  };

  services.caddy.virtualHosts."mon.stu-dev.me".extraConfig = ''
    reverse_proxy :${builtins.toString config.services.grafana.settings.server.http_port}
  '';

  services.grafana = {
    enable = true;

    settings = {
      smtp = {
        enabled = true;
        host = "mail.stu-dev.me";
        user = "mail@stu-dev.me";
        password = "$__file{${config.age.secrets.grafanaSmtpPassword.path}}";
      };

      server = {
        http_addr = "127.0.0.1";
        http_port = 33004;
        domain = "mon.stu-dev.me";
      };

      security = {
        admin_user = "stu";
        admin_email = "mail@stu-dev.me";
        admin_password = "$__file{${config.age.secrets.grafanaAdminPassword.path}}";
      };
    };
  };

  services.prometheus = {
    enable = true;

    exporters.node = {
      enable = true;
      enabledCollectors = ["systemd"];
    };

    scrapeConfigs = [
      {
        job_name = "win-workstation";
        scrape_interval = "5s";
        scrape_timeout = "3s";
        static_configs = [
          {
            targets = ["stusworkstation:4445"];
          }
        ];
      }
    ];
  };
}
