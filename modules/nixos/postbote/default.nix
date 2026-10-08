{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.my.postbote;
  tunnelId = "f3bb1152-ff1c-473f-bb1a-221591433d87";
in
{
  options.my.postbote = {
    enable = mkEnableOption "postbote, the mail MCP server";

    domain = mkOption {
      type = types.str;
      default = "postbote.jukl.dev";
      description = "Public hostname, served through Rome's Cloudflare tunnel.";
    };
  };

  # Accounts and their agenix secrets are added per mailbox; see README.md.
  config = mkIf cfg.enable {
    services.postbote = {
      enable = true;
      publicUrl = "https://${cfg.domain}";
      trustedProxy = "cloudflare";
    };

    my = {
      cloudflare-tunnel.enable = true;

      # No backup: the state holds a plaintext index of mail (rebuildable from IMAP) and OAuth
      # tokens (a re-login replaces them).
      persist.directories = [
        {
          directory = "/var/lib/postbote";
          user = "postbote";
          group = "postbote";
          mode = "0700";
        }
      ];
    };

    # Public through the tunnel; postbote itself only listens on loopback.
    services.cloudflared.tunnels.${tunnelId}.ingress.${cfg.domain} =
      "http://${config.services.postbote.listen}";
  };
}
