# CLIProxyAPI on rome

Runs the fork [Stupremee/CLIProxyAPI](https://github.com/Stupremee/CLIProxyAPI)
through its NixOS module (flake input `cliproxyapi`) as the native
`cliproxyapi.service`, user `cliproxyapi`, state in `/var/lib/cliproxyapi`.
The management panel, OpenCode Go provider and Analysis page are built into
the binary, so there is no pinned panel, plugin or Keeper container.

- `127.0.0.1:8318` (Caddy): public API at `cliproxy.stu-dev.me`; management
  paths return 404.
- `127.0.0.1:8319` (Caddy): admin origin at `cliproxy-admin.stu-dev.me`;
  management needs the management key.
- `:8317` (CLIProxyAPI): loopback and tailnet only. Nodes tagged
  `tag:laptop` open `http://rome:8317/management.html` without the key.

`config.yaml` is mutable. On every start `cliproxyapi-migrate` (root
`ExecStartPre`) sets the keys Nix owns, in whichever layout the file uses:
the docker-era `auth-dir`, Analysis `enable`, and the Tailscale management
auth. While `/var/lib/cpa-usage-keeper/data/app.db` exists it also imports the
Keeper history once (marker `.keeper-imported`).

Bump the binary with `nix flake update cliproxyapi`, then deploy with
`nix run .# -- rome`.
