# postbote on rome

Runs [Stupremee/postbote](https://github.com/Stupremee/postbote) through its NixOS module (flake
input `postbote`) as `postbote.service`, user `postbote`, state in `/var/lib/postbote`.

- `https://postbote.jukl.dev` is public through the Cloudflare tunnel (ingress to
  `127.0.0.1:8425`, DNS: proxied CNAME `postbote.jukl.dev` -> `<tunnel-id>.cfargotunnel.com`);
  `trustedProxy = "cloudflare"` makes rate limits use `CF-Connecting-IP`.
- MCP endpoint: `https://postbote.jukl.dev/mcp` for every account. Sign in with the account name,
  its password and TOTP; a second mailbox is a second connector with the same URL. Static tokens
  pick their account themselves.
- State is persisted but not backed up: the index is a plaintext copy of mail and can be rebuilt
  from IMAP; OAuth tokens are replaced by logging in again.

## Adding an account

1. Generate the login secrets on any machine with postbote
   (`nix run git+ssh://git@github.com/Stupremee/postbote --`):
   `postbote hash-password` (use it for every account so all hashes share the same cost) and
   `postbote totp-generate --account <name>` (scan the QR code). For agents that send headers:
   `postbote token generate` (keep the token, store the hash).
2. Create agenix secrets (`agenix edit`, then `agenix rekey -a` with the YubiKey):
   `postbote-<name>-imap`, `postbote-<name>-login`, `postbote-<name>-totp`, optional
   `postbote-<name>-token-<t>`.
3. Add `services.postbote.accounts.<name>` (`<name>` is what you type at sign-in) (see the postbote repo's `nix/README.md`), deploy with
   `nix run .# -- rome`, then check `sudo postbote-ctl doctor` on rome (needs the service running).

For Proton, IMAP goes through Proton Bridge on loopback (STARTTLS on 1143); pin its certificate
with `imap.pinnedCertFile`.
