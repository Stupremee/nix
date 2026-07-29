# Plan 003: Stop services from bypassing the firewall and the auth proxy

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 3327631..HEAD -- modules/nixos/stremio/default.nix modules/nixos/pdf/default.nix modules/nixos/oidc/default.nix modules/nixos/sunspec-modbus-server/default.nix modules/nixos/home-assistant/default.nix`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- **Priority**: P1
- **Effort**: S
- **Risk**: MED
- **Depends on**: none
- **Category**: security
- **Planned at**: commit `3327631`, 2026-07-29

## Why this matters

Three separate exposure problems on the `rome` server:

1. **The Stremio container publishes ports on all interfaces.** Docker inserts
   its DNAT rules ahead of the NixOS firewall chain, so published container
   ports are reachable regardless of `networking.firewall.allowedTCPPorts`.
   This is the one service on the host that escapes the firewall entirely, and
   it also sets `NO_CORS=1`. Caddy already proxies it, so the published ports
   are redundant.

2. **The SunSpec Modbus server binds `0.0.0.0` with `openFirewall = true`.**
   Modbus TCP has no authentication. Every host on the LAN and on the tailnet
   can read live household energy telemetry. The server is read-only (writes
   are rejected), which caps the impact to disclosure rather than actuation.

3. **Three public vhosts have no forward-auth**, including the LLDAP admin UI
   which manages the identity store. Authelia declares `default_policy = "deny"`
   with a blanket `*.stu-dev.me` rule, and a ready-to-use `(authelia)` Caddy
   snippet exists — but only two vhosts import it. That makes the deny-by-default
   policy misleading: it is only enforced where a vhost opts in.

Note on current reachability: ports 80/443 are **not** in
`allowedTCPPorts` on `rome`, so Caddy appears reachable only over the trusted
`tailscale0` interface. That caps today's blast radius, but it means a single
future `allowedTCPPorts = [ 443 ]` silently turns the unauthenticated vhosts
into anonymous internet endpoints.

## Current state

`modules/nixos/stremio/default.nix:34-56`:

```nix
  config = mkIf cfg.enable {
    # Ensure docker is enabled
    my.docker.enable = true;

    # Stremio server container
    virtualisation.oci-containers.containers.stremio = {
      image = "stremio/server:latest";
      ports = [
        "${toString cfg.httpPort}:11470"
        "${toString cfg.httpsPort}:12470"
      ];
      environment = {
        NO_CORS = "1";
      };
      extraOptions = [ "--pull=always" ];
    };

    # Caddy reverse proxy for HTTP port
    services.caddy.virtualHosts.${cfg.domain}.extraConfig = ''
      import cloudflare
      reverse_proxy :${toString cfg.httpPort}
    '';
  };
```

`modules/nixos/home-assistant/default.nix:134-143` — the sunspec call site:

```nix
    services.sunspecModbusServer = {
      enable = true;
      host = "0.0.0.0";
      port = 1502;
      unitId = 1;
      baseAddress = 40000;
      pollIntervalSeconds = 5;
      logLevel = "INFO";
      dataSource = "homeAssistant";
      openFirewall = true;
```

`modules/nixos/sunspec-modbus-server/default.nix:72-76` — the module default:

```nix
    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Address to bind the Modbus TCP server to.";
    };
```

The **existing, working** auth snippet — `modules/nixos/caddy/default.nix:32-37`:

```nix
        (authelia) {
          forward_auth localhost:9091 {
            uri /api/authz/forward-auth
            copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
          }
        }
```

And the two vhosts that use it correctly —
`modules/nixos/home-assistant/default.nix:24-34`:

```nix
    services.caddy.virtualHosts."esp.stu-dev.me".extraConfig = ''
      import cloudflare
      import authelia
      reverse_proxy :${toString config.services.esphome.port}
    '';
```

The three that do not:
- `modules/nixos/pdf/default.nix:17-20` — `pdf.stu-dev.me` (Stirling PDF)
- `modules/nixos/oidc/default.nix:84-87` — `ldap.stu-dev.me` (LLDAP admin UI)
- `modules/nixos/stremio/default.nix:52-55` — `stremio.stu-dev.me`

## Commands you will need

| Purpose | Command | Expected on success |
|---|---|---|
| Format | `nix fmt` | exit 0 |
| Evaluate rome | `nix eval .#nixosConfigurations.rome.config.system.build.toplevel.drvPath` | prints store path, exit 0 |
| Inspect firewall | `nix eval --json .#nixosConfigurations.rome.config.networking.firewall.allowedTCPPorts` | see steps |

## Scope

**In scope**:
- `modules/nixos/stremio/default.nix`
- `modules/nixos/pdf/default.nix`
- `modules/nixos/oidc/default.nix` (the `ldap.stu-dev.me` vhost block **only**)
- `modules/nixos/sunspec-modbus-server/default.nix` (the `host` option default **only**)
- `modules/nixos/home-assistant/default.nix` (the `services.sunspecModbusServer` block **only**)

**Out of scope** (do NOT touch, even though they look related):
- The `age.secrets` block in `modules/nixos/oidc/default.nix` — owned by plan 001.
  Only touch the `virtualHosts` lines.
- `modules/nixos/unifi/default.nix` — the extra ports 38080/38443 there need a
  live `ss -lntup` check on the host to confirm they are unused; that is an
  operator action, not an executor action. Leave it alone and note it in your report.
- `configurations/nixos/rome/default.nix:85` (`allowedUDPPorts = [ 20000 ]`) —
  same reason; undocumented but needs live verification before removal.
- `modules/nixos/docker/default.nix` — container hardening defaults are a
  separate, larger change.

## Git workflow

- Branch: `advisor/003-network-exposure`
- Commit per logical unit (stremio / sunspec / vhost auth), terse
  `scope: summary` messages e.g. `stremio: bind container ports to loopback`.
- Do NOT push or open a PR unless the operator instructed it.

## Steps

### Step 1: Bind the Stremio container ports to loopback

In `modules/nixos/stremio/default.nix`, prefix both port mappings with
`127.0.0.1:` so Docker publishes only on the loopback interface. Caddy proxies
to `:${toString cfg.httpPort}` on the host, which still works over loopback.

Target shape:

```nix
      ports = [
        "127.0.0.1:${toString cfg.httpPort}:11470"
        "127.0.0.1:${toString cfg.httpsPort}:12470"
      ];
```

**Verify**: `grep -n '127.0.0.1:' modules/nixos/stremio/default.nix` → two matches.

### Step 2: Remove `NO_CORS` from the Stremio container

Delete the `environment = { NO_CORS = "1"; };` block.

**Caveat to check first**: Stremio web clients loaded from a different origin
may require permissive CORS. If you find any evidence in the repo that a
browser client at another origin talks to this server directly, STOP and report
instead of removing it. (Grep: `grep -rn "stremio" modules/ configurations/`.)

**Verify**: `grep -n 'NO_CORS' modules/nixos/stremio/default.nix` → no matches.

### Step 3: Add forward-auth to the three unauthenticated vhosts

Add `import authelia` immediately after `import cloudflare` in each of:

- `modules/nixos/pdf/default.nix` (the `pdf.stu-dev.me` vhost)
- `modules/nixos/oidc/default.nix` (the `ldap.stu-dev.me` vhost — **not** the
  `auth.stu-dev.me` vhost, which is Authelia itself and must stay open or you
  create a redirect loop)
- `modules/nixos/stremio/default.nix` (the `stremio.stu-dev.me` vhost)

**This is the highest-risk step.** Adding forward-auth to `auth.stu-dev.me`
would lock out the login page itself. Confirm before editing that you are not
touching the `auth.` vhost at `modules/nixos/oidc/default.nix:89-92`.

**Verify**:
```
grep -c 'import authelia' modules/nixos/pdf/default.nix modules/nixos/oidc/default.nix modules/nixos/stremio/default.nix modules/nixos/home-assistant/default.nix
```
→ pdf: 1, oidc: 1, stremio: 1, home-assistant: 2 (the pre-existing esp + zigbee).

And confirm `auth.stu-dev.me` was NOT given forward-auth:
```
grep -A2 'auth.stu-dev.me' modules/nixos/oidc/default.nix
```
→ must show `import cloudflare` and `reverse_proxy :9091` with no `import authelia`.

### Step 4: Change the SunSpec module default to loopback

In `modules/nixos/sunspec-modbus-server/default.nix`, change the `host` option
default from `"0.0.0.0"` to `"127.0.0.1"` so the safe choice is the default.
Update the option `description` to note that exposing it to a network requires
an explicit override.

**Do not** change the call site's binding in this step — the heat pump needs to
reach it, and picking the right address requires knowing the LAN interface.

**Verify**: `grep -n 'default = "127.0.0.1"' modules/nixos/sunspec-modbus-server/default.nix` → one match.

### Step 5: Document the SunSpec exposure decision at the call site

In `modules/nixos/home-assistant/default.nix`, leave `host = "0.0.0.0"` and
`openFirewall = true` **as they are**, but add a comment above the
`services.sunspecModbusServer` block recording that this is a deliberate LAN
exposure for the heat pump, and that narrowing it to the heat pump's address or
subnet is a pending operator task requiring the device's IP.

Rationale for not changing it here: binding to a specific address without
knowing which interface the heat pump uses would silently break the export
simulation, and that has physical consequences.

**Verify**: `nix eval --json .#nixosConfigurations.rome.config.networking.firewall.allowedTCPPorts`
→ still contains `1502` (unchanged behavior).

### Step 6: Format and evaluate

```
nix fmt
nix eval .#nixosConfigurations.rome.config.system.build.toplevel.drvPath
```

**Verify**: exit 0.

## Test plan

No module test suite exists; evaluation plus declarative inspection is the gate.

- `nix eval .#nixosConfigurations.rome.config.system.build.toplevel.drvPath` → exits 0.
- Confirm the Stremio port bindings landed:
  `nix eval --json .#nixosConfigurations.rome.config.virtualisation.oci-containers.containers.stremio.ports`
  → both entries start with `127.0.0.1:`.
- Confirm the Caddy config contains the auth import for the three vhosts:
  `nix eval --raw .#nixosConfigurations.rome.config.services.caddy.configFile` is
  a store path; instead grep the generated virtualHost config via
  `nix eval --json .#nixosConfigurations.rome.config.services.caddy.virtualHosts --apply 'builtins.mapAttrs (_: v: v.extraConfig)'`
  and confirm `ldap.stu-dev.me`, `pdf.stu-dev.me`, `stremio.stu-dev.me` each
  contain `import authelia`, and `auth.stu-dev.me` does not.

## Done criteria

ALL must hold:

- [ ] `grep -n 'NO_CORS' modules/nixos/stremio/default.nix` → no matches
- [ ] Stremio's two port entries both begin with `127.0.0.1:`
- [ ] `ldap.stu-dev.me`, `pdf.stu-dev.me`, `stremio.stu-dev.me` each contain `import authelia`
- [ ] `auth.stu-dev.me` does NOT contain `import authelia`
- [ ] `modules/nixos/sunspec-modbus-server/default.nix` `host` default is `"127.0.0.1"`
- [ ] `nix eval .#nixosConfigurations.rome.config.system.build.toplevel.drvPath` exits 0
- [ ] `nix fmt` produces no further diff
- [ ] No files outside the in-scope list are modified (`git status`)
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report back (do not improvise) if:

- Any "Current state" excerpt does not match the live file.
- You find evidence that a browser client at a different origin needs
  `NO_CORS` (Step 2).
- Adding `import authelia` to a vhost would affect `auth.stu-dev.me`.
- Changing the sunspec module default breaks evaluation because some other
  caller relied on `0.0.0.0`.
- You are tempted to also "fix" the unifi ports or the UDP 20000 rule — those
  are explicitly out of scope and need live host verification first.

## Maintenance notes

- **The most important follow-up is not in this plan**: narrowing the SunSpec
  bind to the heat pump's address, and confirming with `ss -lntup` on `rome`
  whether unifi's 38080/38443 and UDP 20000 are actually in use. Both need
  live access to the host.
- After Step 3, adding a new public vhost should default to including
  `import authelia`. A reviewer should treat any new vhost without it as
  needing an explicit justification comment.
- The Stremio container still uses the floating `stremio/server:latest` tag
  with `--pull=always`, so rebuilds deploy unreviewed upstream code. Pinning to
  a digest was considered and deferred — it is a separate change and requires
  choosing a digest.
