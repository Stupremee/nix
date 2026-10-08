# postbote on rome

Runs [Stupremee/postbote](https://github.com/Stupremee/postbote) through its NixOS module (flake
input `postbote`) as `postbote.service`, user `postbote`, state in `/var/lib/postbote`.

- `https://postbote.jukl.dev` is public through the Cloudflare tunnel (ingress to
  `127.0.0.1:8425`, DNS: proxied CNAME `postbote.jukl.dev` -> `<tunnel-id>.cfargotunnel.com`);
  `trustedProxy = "cloudflare"` makes rate limits use `CF-Connecting-IP`.
- MCP endpoint: `https://postbote.jukl.dev/mcp` for every account. To connect a client, run
  `sudo postbote-ctl pair` on rome (`--account <name>` for one mailbox), paste the code into the
  sign-in page and pick the mailbox; a second mailbox is a second connector with the same URL and
  a new code. Static tokens pick their account themselves.
- State is persisted but not backed up: the index is a plaintext copy of mail and can be rebuilt
  from IMAP; OAuth tokens are replaced by signing in again with a new code.

## Adding an account

1. For agents that send headers, optionally generate a static token on any machine with postbote
   (`nix run git+ssh://git@github.com/Stupremee/postbote -- token generate`; keep the token,
   store the hash).
2. Create agenix secrets (`agenix edit`, then `agenix rekey -a` with the YubiKey):
   `postbote-<name>-imap`, optional `postbote-<name>-token-<t>`.
3. Add `services.postbote.accounts.<name>` (`<name>` is what the sign-in page offers; see the
   postbote repo's `nix/README.md`), deploy with `nix run .# -- rome`, check
   `sudo postbote-ctl doctor` on rome (needs the service running), then connect clients with
   `sudo postbote-ctl pair`.

For Proton, IMAP goes through Proton Bridge on loopback (STARTTLS on 1143); pin its certificate
with `imap.pinnedCertFile`.

## Account `proton`

Bridge runs as `stu`'s user service (`my.protonmail-bridge`, vault key in `pass`). Mail goes out
through Bridge's SMTP (STARTTLS on 1025, same password). Without Pushover, approve sends on rome
with `sudo postbote-ctl approve`. Bridge's certificate (IMAP and SMTP) is pinned from
`proton-bridge-cert.pem`. When Bridge generates a new one (new vault,
re-login), `doctor` fails with a pinning error; refresh the file on rome:

```sh
openssl s_client -starttls imap -connect 127.0.0.1:1143 </dev/null 2>/dev/null \
  | openssl x509 -outform PEM > proton-bridge-cert.pem
```
