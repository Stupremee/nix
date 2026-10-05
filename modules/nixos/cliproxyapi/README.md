# CLIProxyAPI on rome

Runs the fork [Stupremee/CLIProxyAPI](https://github.com/Stupremee/CLIProxyAPI)
through its NixOS module (flake input `cliproxyapi`) as the native
`cliproxyapi.service`, user `cliproxyapi`, state in `/var/lib/cliproxyapi`.
The management panel, OpenCode Go provider and Analysis page are built into
the binary, so there is no pinned panel, plugin or Keeper container.

CLIProxyAPI is tailnet-only; the Cloudflare tunnel publishes no hostnames for it.

- `https://cliproxy.jukl.dev` (Caddy, resolves to rome's tailnet address): API
  and panel. Caddy is the trusted proxy, so nodes tagged `tag:laptop` open the
  panel without the management key.
- `127.0.0.1:8318` (Caddy): API only; management paths return 404.
- `:8317` (CLIProxyAPI): loopback and tailnet only.

`config.yaml` is mutable. On every start `cliproxyapi-migrate` (root
`ExecStartPre`) sets the keys Nix owns, in whichever layout the file uses:
the docker-era `auth-dir`, `trusted-proxies` (Caddy on loopback), Analysis
`enable`, the Tailscale management auth, and `restrict-oauth-to-claude-code`
(Claude OAuth logins only serve Claude Code). The Keeper history was imported once on 2026-10-03; to import another
Keeper database run `cli-proxy-api --config config.yaml --import-keeper-db <app.db>`.

Bump the binary with `nix flake update cliproxyapi`, then deploy with
`nix run .# -- rome`.
