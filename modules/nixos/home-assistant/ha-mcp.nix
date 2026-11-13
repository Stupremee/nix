{
  lib,
  pkgsUnstable,
  config,
  ...
}:
let
  port = 8086;
  stateDir = "/var/lib/ha-mcp";
  tailscale = lib.getExe config.services.tailscale.package;
in
lib.mkIf config.my.home-assistant.enable {
  # MCP server for AI clients, tailnet only at https://<host>.<tailnet>.ts.net:8086.
  # Not every client manages OAuth, so it runs with one long-lived token, and the
  # secret endpoint path is the credential. Token and paths live in ha-mcp.env:
  # HOMEASSISTANT_TOKEN, MCP_SECRET_PATH, MCP_SETTINGS_SECRET_PATH.
  age.secrets."ha-mcp.env".rekeyFile = ../../../secrets/ha-mcp.env.age;

  users.users.ha-mcp = {
    isSystemUser = true;
    group = "ha-mcp";
  };
  users.groups.ha-mcp = { };

  systemd.services.ha-mcp = {
    description = "Home Assistant MCP server";
    after = [
      "network-online.target"
      "home-assistant.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      HOMEASSISTANT_URL = "http://127.0.0.1:8123";
      MCP_HOST = "127.0.0.1";
      MCP_PORT = toString port;
      # Settings, tool config and backups taken before edits.
      HA_MCP_CONFIG_DIR = stateDir;
    };
    serviceConfig = {
      ExecStart = "${pkgsUnstable.ha-mcp}/bin/ha-mcp-web";
      EnvironmentFile = config.age.secrets."ha-mcp.env".path;
      User = "ha-mcp";
      Group = "ha-mcp";
      StateDirectory = "ha-mcp";
      StateDirectoryMode = "0700";
      Restart = "on-failure";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
    };
  };

  systemd.services.ha-mcp-tailscale-serve = {
    description = "Home Assistant MCP Tailscale Serve";
    after = [ "tailscaled.service" ];
    requires = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStartPre = "${tailscale} wait";
      ExecStart = "${tailscale} serve --bg --https=${toString port} http://127.0.0.1:${toString port}";
      ExecStop = "${tailscale} serve --https=${toString port} off";
    };
  };

  my.persist.directories = [
    {
      directory = stateDir;
      user = "ha-mcp";
      group = "ha-mcp";
      mode = "0700";
    }
  ];
}
