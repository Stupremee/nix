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

      # Through Proton Bridge on loopback (my.protonmail-bridge), pinned to its self-signed cert.
      accounts.proton = {
        imap = {
          host = "127.0.0.1";
          port = 1143;
          security = "starttls";
          pinnedCertFile = ./proton-bridge-cert.pem;
          username = "justus.k@protonmail.com";
          passwordFile = config.age.secrets.postbote-proton-imap.path;
        };
        permissions = [
          "read"
          "draft"
          "organize"
        ];
        index = {
          since = "2023-01-01";
          # Bridge exposes "All Mail", "Starred" and every label as a folder; indexing them
          # duplicates mail.
          excludeFolders = [
            "All Mail"
            "Starred"
            "Labels/*"
            "Spam"
            "Trash"
          ];
        };
      };
    };

    # Root-owned: systemd reads it for LoadCredential, postbote never touches the file.
    age.secrets.postbote-proton-imap.rekeyFile = ../../../secrets/postbote-proton-imap.age;

    my = {
      cloudflare-tunnel.enable = true;

      # No backup: the state holds a plaintext index of mail (rebuildable from IMAP) and OAuth
      # tokens (a new pairing replaces them).
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
