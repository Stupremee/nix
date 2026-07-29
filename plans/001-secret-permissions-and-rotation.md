# Plan 001: Remove world-readable modes from agenix secrets and rotate the exposed credentials

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 3327631..HEAD -- modules/nixos/oidc/default.nix modules/nixos/niks3/default.nix`
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

Three agenix secrets are decrypted to `/run/agenix` with mode `444`
(world-readable). One of them is the LLDAP admin password — the master
credential for the identity store that sits behind Authelia, so reading it
yields access to every account it fronts. The other two are the Cloudflare
origin certificate and the cloudflared tunnel credential, which authorize
creating and deleting tunnels and DNS routes for the whole zone, not just
running the existing tunnel.

Every local account on `rome` can read these today — including the service
accounts for Paperless, Home Assistant, esphome, and the Stremio Docker
container. The author already flagged this: `modules/nixos/oidc/default.nix:70`
carries the comment `# FIXME: do not make password public`.

Because these files have been readable by every local process, fixing the mode
is not sufficient — the credentials must be rotated as well.

## Current state

Files in scope and their role:

- `modules/nixos/oidc/default.nix` — Authelia + LLDAP module. Declares the
  agenix secrets for the identity stack.
- `modules/nixos/niks3/default.nix` — binary cache + cloudflared tunnel module.
  Currently disabled on `rome` but its secrets are still rekeyed and deployed.

`modules/nixos/oidc/default.nix:56-82` — note that the `secret` helper already
sets a correct owner/group, and only `lldap-user-pass` bypasses it:

```nix
    age.secrets =
      let
        secret =
          attrs:
          {
            owner = "authelia-main";
            group = "authelia-main";
          }
          // attrs;
      in
      {
        lldap-env.rekeyFile = ../../../secrets/lldap.env.age;
        lldap-user-pass = {
          rekeyFile = ../../../secrets/lldap-user-pass.age;
          # FIXME: do not make password public
          mode = "444";
        };

        authelia-private-key = secret { rekeyFile = ../../../secrets/authelia-private-key.age; };
```

`modules/nixos/niks3/default.nix:34-41`:

```nix
        cloudflared-tunnel = {
          rekeyFile = ../../../secrets/rome-cloudflare-tunnel.age;
          mode = "444";
        };
        cloudflared-cert = {
          rekeyFile = ../../../secrets/cloudflared-cert.age;
          mode = "444";
        };
```

**Repo convention to follow**: secrets are given `owner`/`group` matching the
consuming service's runtime user. The exemplar is the `secret` helper at
`modules/nixos/oidc/default.nix:58-64` (shown above) and the niks3 helper at
`modules/nixos/niks3/default.nix:22-27`, which derives the user from the
service module itself:

```nix
        secret = path: {
          rekeyFile = path;
          owner = config.services.niks3.user;
          group = config.services.niks3.group;
        };
```

**Why `mode = "444"` was likely added**: both LLDAP and cloudflared run under
systemd `DynamicUser`, where the runtime UID does not exist at activation time,
so a static `owner` string fails. The correct modern answer is systemd
credentials (`LoadCredential`), which the repo already uses correctly at
`modules/nixos/sunspec-modbus-server/default.nix:276-278`:

```nix
        LoadCredential = optional (
          cfg.homeAssistant.tokenFile != null
        ) "home-assistant-token:${cfg.homeAssistant.tokenFile}";
```

## Commands you will need

| Purpose | Command | Expected on success |
|---|---|---|
| Format | `nix fmt` | exit 0 |
| Evaluate rome | `nix eval .#nixosConfigurations.rome.config.system.build.toplevel.drvPath` | prints a `/nix/store/...drv` path, exit 0 |
| Check mode is gone | `grep -rn 'mode = "444"' modules/` | no matches |
| Flake check | `nix flake check --no-build` | exit 0 |

Note: `nix fmt` uses `nixfmt-rfc-style` via treefmt (`modules/flake/treefmt.nix:13-19`).

## Scope

**In scope**:
- `modules/nixos/oidc/default.nix`
- `modules/nixos/niks3/default.nix`

**Out of scope** (do NOT touch, even though they look related):
- `secrets/**` — never hand-edit rekeyed or encrypted files; rekeying is a
  separate operator action requiring the YubiKey.
- `modules/nixos/secrets/default.nix` — the agenix-rekey wiring is addressed
  by plan 002; changing it here creates a merge conflict.
- Any other `age.secrets` declaration that does not set `mode`.

## Git workflow

- Branch: `advisor/001-secret-permissions`
- Commit message style matches this repo's terse `scope: summary` convention
  (see `git log --oneline`: `niks3: add module for deploying binary cache`,
  `hass: add modbus file`). Use e.g. `oidc: stop making lldap password world-readable`.
- Do NOT push or open a PR unless the operator instructed it.

## Steps

### Step 1: Determine how LLDAP and cloudflared actually run

Before changing anything, establish whether each service uses `DynamicUser`.
Run:

```
nix eval --raw .#nixosConfigurations.rome.config.systemd.services.lldap.serviceConfig.DynamicUser 2>&1
nix eval --raw .#nixosConfigurations.rome.config.systemd.services.lldap.serviceConfig.User 2>&1
```

Record the answers. Repeat for `cloudflared-tunnel-rome` (the unit name may
differ; list units with
`nix eval --json .#nixosConfigurations.rome.config.systemd.services --apply 'builtins.attrNames' | tr ',' '\n' | grep -i cloud`).

**Verify**: you can state, for each of LLDAP and cloudflared, either a concrete
static `User=` value or that `DynamicUser=true`.

**This determines which branch of Step 2 you take.** If you cannot determine it,
that is a STOP condition.

### Step 2a: If the service has a static user — set owner/group

Replace the `mode = "444"` entry with owner/group, following the `secret`
helper convention already in the file. For `lldap-user-pass` in
`modules/nixos/oidc/default.nix`, the target shape is:

```nix
        lldap-user-pass = {
          rekeyFile = ../../../secrets/lldap-user-pass.age;
          owner = config.services.lldap.user;
          group = config.services.lldap.group;
        };
```

Only use `config.services.lldap.user` if that option actually exists — verify
with `nix eval --raw .#nixosConfigurations.rome.config.services.lldap.user`.
If it does not exist, use the literal user name you established in Step 1.

### Step 2b: If the service uses DynamicUser — use LoadCredential

Do **not** set `owner`. Instead drop `mode` entirely (leaving the default
`0400`, root-owned) and pass the secret to the unit as a systemd credential.
The pattern, modeled on `modules/nixos/sunspec-modbus-server/default.nix:276-278`:

```nix
    systemd.services.<unit>.serviceConfig.LoadCredential = [
      "<name>:${config.age.secrets.<secret>.path}"
    ];
```

and point the service's own file option at `%d/<name>`. If the service module
does not accept a path that can reference `%d`, STOP and report — that means
the fix needs an upstream-module workaround that is out of scope here.

### Step 3: Apply the same treatment to the two cloudflared secrets

`modules/nixos/niks3/default.nix:34-41` — remove both `mode = "444"` lines
using whichever of 2a/2b applies to cloudflared.

Note this module is currently disabled (`configurations/nixos/rome/default.nix:55`
sets `niks3.enable = false`), so this change cannot break a running service.
Do not enable it.

**Verify**: `grep -rn 'mode = "444"' modules/` → no matches.

### Step 4: Format and evaluate

Run `nix fmt`, then:

```
nix eval .#nixosConfigurations.rome.config.system.build.toplevel.drvPath
```

**Verify**: exit 0, prints a store path.

### Step 5: Write the rotation checklist

Create `plans/001-rotation-checklist.md` listing the operator actions that
this plan cannot perform (they require the YubiKey and live access):

1. Rotate the LLDAP admin password; re-encrypt `secrets/lldap-user-pass.age`
   and `secrets/lldap.env.age`; run `agenix rekey`.
2. Rotate the Cloudflare origin certificate and re-issue the tunnel
   credential in the Cloudflare dashboard; re-encrypt
   `secrets/cloudflared-cert.age` and `secrets/rome-cloudflare-tunnel.age`.
3. Deploy and confirm LLDAP and Authelia start cleanly.

Do NOT put any credential value in this file — it lists actions only.

**Verify**: `test -f plans/001-rotation-checklist.md` → exit 0.

## Test plan

This repo has no test suite for NixOS modules; evaluation is the gate.

- `nix eval .#nixosConfigurations.rome.config.system.build.toplevel.drvPath`
  must succeed — this catches option-name and type errors.
- Inspect the resulting mode declaratively rather than by deploying:
  `nix eval --json .#nixosConfigurations.rome.config.age.secrets.lldap-user-pass --apply 'x: { inherit (x) mode owner group; }'`
  → `mode` must not be `"444"`.

## Done criteria

ALL must hold:

- [ ] `grep -rn 'mode = "444"' modules/` returns no matches
- [ ] `nix eval .#nixosConfigurations.rome.config.system.build.toplevel.drvPath` exits 0
- [ ] `nix eval --json .#nixosConfigurations.rome.config.age.secrets.lldap-user-pass --apply 'x: x.mode'` does not print `"444"`
- [ ] `nix fmt` leaves the tree unchanged (`git diff --exit-code` after running it)
- [ ] `plans/001-rotation-checklist.md` exists and contains no credential values
- [ ] No files outside the in-scope list are modified (`git status`)
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report back (do not improvise) if:

- The excerpts in "Current state" do not match the live files.
- You cannot determine from Step 1 whether a service uses `DynamicUser`.
- The service module provides no way to point at a `%d/` credential path
  (Step 2b).
- Removing `mode` makes `nix eval` fail with a permissions or user-not-found
  error — report the exact error rather than reinstating `444`.
- You are tempted to edit anything under `secrets/` — that is always a STOP.

## Maintenance notes

- The real remediation is the rotation in Step 5, not the mode change. A
  reviewer should confirm the rotation actually happened; the config change
  alone leaves burned credentials in place.
- If a future service needs a secret and runs under `DynamicUser`, use
  `LoadCredential` rather than reaching for `mode`. The sunspec module is the
  reference implementation.
- Deferred out of this plan: auditing whether `lldap.env.age` (which holds the
  LLDAP JWT secret) should also move to `LoadCredential`. It is currently mode
  default (0400), so it is not urgent.
