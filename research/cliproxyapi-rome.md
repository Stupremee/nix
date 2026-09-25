# CLIProxyAPI deployment on `rome`

Research and deployment date: 2026-08-31. The deployed image is the official
`eceasy/cli-proxy-api` multi-architecture image at digest
`sha256:238691ac26ce55e4d1c5219d72e3ad74838f81eda26359912eeb415e2820d163`,
which corresponds to upstream release
[`v7.2.146`](https://github.com/router-for-me/CLIProxyAPI/releases/tag/v7.2.146).

## Deployed layout

CLIProxyAPI runs through `virtualisation.oci-containers`. Docker publishes the
API and OAuth callback ports on host loopback only:

- `127.0.0.1:8317` for CLIProxyAPI
- `127.0.0.1:1455` for the Codex OAuth callback
- `127.0.0.1:54545` for the Claude OAuth callback

Caddy has two additional loopback-only listeners:

- `127.0.0.1:8318` is the public API origin. It rejects `/management.html`,
  `/v0/management`, and plugin-resource routes before proxying to CLIProxyAPI.
- `127.0.0.1:8319` is the administrative origin. CLIProxyAPI requires the
  separate management key for its management API; the management page itself
  is publicly reachable. Plugin browser resources retain Authelia protection
  because CLIProxyAPI serves those routes without management-key checks.

Rome's existing locally managed Cloudflare tunnel publishes these origins as:

- `https://cliproxy.stu-dev.me`, with OpenAI-compatible base URL
  `https://cliproxy.stu-dev.me/v1`
- `https://cliproxy-admin.stu-dev.me/management.html`

The Cloudflare connector makes outbound connections only. No inbound firewall
port was opened on Rome. Both public DNS records are proxied CNAMEs to tunnel
`f3bb1152-ff1c-473f-bb1a-221591433d87`.

## Mutable configuration

Nix does not own CLIProxyAPI's live YAML. The first service start creates
`/var/lib/cliproxyapi/config.yaml`, an API key, and a separate management key.
CLIProxyAPI can then update that YAML through its management API and web UI.
Later Nix deployments leave an existing config file untouched.

The state directory is root-owned mode `0700`. The YAML and bootstrap
credential file are mode `0600`. Rome persists and backs up the whole directory
with the repository's existing Restic setup, including provider OAuth files,
logs, and plugins.

The initial YAML enables remote management with a generated management key.
It keeps the API hostname's management paths blocked,
uses a nonempty generated API key, requires WebSocket authentication, disables
plugins, and limits file logs to 512 MB. CLIProxyAPI replaces the plaintext
management key in YAML with a password hash on startup. The original generated
key remains in the root-only bootstrap credential file so the operator can log
in for the first time.

An empty `api-keys` list would make inference routes unauthenticated, so the
bootstrap always creates a strong nonempty key. See the upstream
[configuration reference](https://help.router-for.me/configuration/basic.html)
and [management API documentation](https://help.router-for.me/management/api.html).

## Deployed files

- `modules/nixos/cliproxyapi/default.nix` owns the container, initial bootstrap,
  persistent state, backup registration, and loopback Caddy listeners.
- `modules/nixos/cloudflare-tunnel/default.nix` owns the existing local tunnel
  connector and its two ingress rules.
- `configurations/nixos/rome/default.nix` enables CLIProxyAPI and Usage Keeper.
- `secrets/rekeyed/rome/9214b5a44d0bb39f39d75dbecccf013c-cloudflare-tunnel-rome.age`
  is the Rome-host-encrypted tunnel credential generated from the existing
  YubiKey-encrypted source secret.

## Verified behavior

At the initial deployment with `nix run .# -- rome`:

- the CLIProxyAPI container and Caddy are active;
- the tunnel has four registered edge connections and no warnings;
- all five service ports listen on `127.0.0.1` only;
- `GET https://cliproxy.stu-dev.me/healthz` returns 200;
- unauthenticated `GET /v1/models` returns 401;
- authenticated `GET /v1/models` returns 200;
- management paths on the API hostname return 404;
- the admin hostname redirected to `auth.stu-dev.me` under the original proxy
  configuration;
- the management page returns 200 behind the proxy; and
- both supported management-key headers authenticate successfully.

## Management access and plugin store

Use `https://cliproxy.stu-dev.me/v1` with an API key for inference. Use
`https://cliproxy-admin.stu-dev.me/management.html` with the separate management
key for administration. The revised proxy configuration lets key-authenticated
management requests through without Authelia. Anyone can load the management
page, but the management API requires its key. Plugin browser resources under
`/v0/resource/plugins/*` still require Authelia because CLIProxyAPI serves
them without checking the management key. Keep the management key private and
rotate it if it has been shared.

Plugin store listings and installs query GitHub's release API from Rome. GitHub
can rate-limit those unauthenticated requests, returning 403. CLIProxyAPI
converts a failed release lookup during installation to a 502 response. The
pinned version supports this rule in the live YAML:

```yaml
plugins:
  store-auth:
    - match: "https://api.github.com/"
      apply-to: ["metadata", "artifact"]
      type: github-token
      token-env: "CLIPROXY_PLUGIN_STORE_GITHUB_TOKEN"
```

Nix passes the root-only `/var/lib/cliproxyapi/plugin-store.env` to the
container and creates it empty if missing. Put
`CLIPROXY_PLUGIN_STORE_GITHUB_TOKEN=...` there, using a separate fine-grained
GitHub token with public-repository read access only. Plugins run inside the
CLIProxyAPI process and can read its environment. Add the `store-auth` rule only
after the token is set: CLIProxyAPI fails matching requests when the variable is
empty. Restart `docker-cliproxyapi` after editing the file. The live YAML is mutable and is not overwritten
by Nix deployments. Setting `GITHUB_TOKEN` alone does not authenticate plugin
store requests in this pinned version; the `store-auth` rule is required.

The Restic timer is active and next runs at midnight UTC. A reboot test was not
performed during deployment.

## Usage Keeper

[CPA Usage Keeper](https://github.com/Willxup/cpa-usage-keeper) v1.15.7 stores
CLIProxyAPI usage in SQLite and serves dashboards at
`https://cliproxy-admin.stu-dev.me/keeper/`. It shares the admin origin, so its
"Back to CPA" link reaches `/management.html` without extra configuration.

The container uses host networking and listens on `127.0.0.1:8320`. It
subscribes to CLIProxyAPI's Redis-protocol usage stream on port 8317, which
requires `usage-statistics-enabled: true` in the live YAML. Caddy forwards
`CF-Connecting-IP` as `X-Forwarded-For` so login rate limits apply per client.

The first start writes `/var/lib/cpa-usage-keeper/keeper.env`, a root-only file
holding `CPA_MANAGEMENT_KEY`, copied from the CLIProxyAPI bootstrap credentials,
and a generated `LOGIN_PASSWORD`. Nix never rewrites the file. If the management
key is rotated, edit this file and restart `docker-cpa-usage-keeper`. Keeper's
SQLite database and its daily backups are in `/var/lib/cpa-usage-keeper/data`,
which is persisted and included in Restic backups.

`AUTH_ENABLED=true` is set explicitly because v1.9.1 defaulted it to false even
though the README says the default is true.
