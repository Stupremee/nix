{
  lib,
  config,
  ...
}:
let
  cfg = config.my.trakt-mcp;
  port = 8087;
  stateDir = "/var/lib/trakt-mcp";
  tailscale = lib.getExe config.services.tailscale.package;
in
{
  options.my.trakt-mcp.enable = lib.mkEnableOption "Trakt MCP server";

  # Tailnet only at https://<host>.<tailnet>.ts.net:8087/mcp. One Trakt account
  # signs in once via the start_device_auth tool, then every client uses it.
  # trakt-mcp.env holds TRAKT_CLIENT_ID.
  config = lib.mkIf cfg.enable {
    my.docker.enable = true;

    age.secrets."trakt-mcp.env".rekeyFile = ../../../secrets/trakt-mcp.env.age;

    virtualisation.oci-containers.containers.trakt-mcp = {
      image = "ghcr.io/wwiens/trakt_mcpserver:0.11.2";
      ports = [ "127.0.0.1:${toString port}:8080" ];
      volumes = [ "${stateDir}:/data" ];
      environmentFiles = [ config.age.secrets."trakt-mcp.env".path ];
    };

    systemd.services.trakt-mcp-tailscale-serve = {
      description = "Trakt MCP Tailscale Serve";
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

    # The image writes the Trakt token to /data as uid 1000, which is stu here.
    my.persist.directories = [
      {
        directory = stateDir;
        user = "stu";
        mode = "0700";
      }
    ];
  };
}
