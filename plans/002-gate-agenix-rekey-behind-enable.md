# Plan 002: Make `my.secrets.enable` actually gate agenix-rekey, and remove the dummy-pubkey fallback

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 3327631..HEAD -- modules/nixos/secrets/default.nix configurations/nixos/baldon/default.nix configurations/nixos/rome/default.nix`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- **Priority**: P1
- **Effort**: S
- **Risk**: LOW
- **Depends on**: none
- **Category**: security
- **Planned at**: commit `3327631`, 2026-07-29

## Why this matters

`modules/nixos/secrets/default.nix` declares an option `my.secrets.enable`, but
its `config` block is **not** wrapped in `mkIf cfg.enable` — so every NixOS host
gets agenix-rekey wired up unconditionally, whether or not it opted in.

The host that never opted in is `baldon`, and because it never sets
`my.secrets.sshKey`, it falls back to `dummyPubkey` — a hardcoded, publicly
known age key literal at `modules/nixos/secrets/default.nix:13`. This means
agenix-rekey treats `baldon` as a live rekey target and would encrypt any
secret defined on it to a key that is in this public repository and in the
agenix-rekey upstream docs.

Nothing is currently exposed, because `baldon` defines no secrets today. The
finding is that the safety mechanism is inverted: the `enable` flag implies
opt-in while the code is opt-out, and the failure mode when someone adds a
secret to `baldon` is silent rather than loud.

## Current state

`modules/nixos/secrets/default.nix` in full (53 lines). The critical part —
note `config = {` on line 43 with no `mkIf`:

```nix
{
  lib,
  config,
  flake,
  ...
}:
with lib;
let
  inherit (flake.inputs) self;

  cfg = config.my.secrets;

  dummyPubkey = "age1qyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqs3290gq";

in
{
  options.my.secrets = with lib; {
    enable = mkEnableOption "Enable secrets via agenix-rekey";

    sshKey = mkOption {
      type = with types; coercedTo path (x: if isPath x then readFile x else x) str;
      description = ''
        ... (long description) ...
      '';
      default = dummyPubkey;
      example = literalExpression "./secrets/host1.pub";
    };
  };

  config = {
    age.rekey = {
      hostPubkey = cfg.sshKey;

      masterIdentities = [ ../../../secrets/master-keys/yubikey-c.age ];
      storageMode = "local";
      generatedSecretsDir = self.outPath + "/secrets/generated/${config.networking.hostName}";
      localStorageDir = self.outPath + "/secrets/rekeyed/${config.networking.hostName}";
    };
  };
}
```

The only host that enables it, `configurations/nixos/rome/default.nix:44-47`:

```nix
    secrets = {
      enable = true;
      sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJEFO0TbdOgpnHFhsnHwi+VB/FMTGrTiXJtPcY+1lslT";
    };
```

`configurations/nixos/baldon/default.nix` never mentions `secrets` at all —
confirm with `grep -n secrets configurations/nixos/baldon/default.nix`.

**How this module reaches every host**: `modules/nixos/default.nix:15` imports
every module in `modules/nixos/` via
`attrValues (filterAttrs (name: _: name != "default") flake.inputs.self.nixosModules)`.
There is no per-host import list — that is why an ungated `config` block
applies everywhere.

**Repo convention to follow**: every other module in `modules/nixos/` uses the
shape `config = mkIf cfg.enable { ... }`. Exemplar —
`modules/nixos/openssh/default.nix:12-30`:

```nix
  options.my.openssh = {
    enable = mkEnableOption "Enable default settings for openssh";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ...
    };
  };
```

## Commands you will need

| Purpose | Command | Expected on success |
|---|---|---|
| Format | `nix fmt` | exit 0 |
| Evaluate rome | `nix eval .#nixosConfigurations.rome.config.system.build.toplevel.drvPath` | prints store path, exit 0 |
| Evaluate baldon | `nix eval .#nixosConfigurations.baldon.config.system.build.toplevel.drvPath` | prints store path, exit 0 |
| Check baldon's rekey pubkey | `nix eval --raw .#nixosConfigurations.baldon.config.age.rekey.hostPubkey` | see Step 3 |

## Scope

**In scope**:
- `modules/nixos/secrets/default.nix`

**Out of scope** (do NOT touch, even though they look related):
- `configurations/nixos/rome/default.nix` — already sets `enable = true`
  correctly; no change needed.
- `configurations/nixos/baldon/default.nix` — leaving it without secrets is
  the intended outcome. Do NOT add `secrets.enable = true` to it.
- `modules/nixos/oidc/default.nix` and `modules/nixos/niks3/default.nix` —
  owned by plan 001.
- `secrets/**` — never hand-edit.

## Git workflow

- Branch: `advisor/002-gate-secrets`
- Commit message style: terse `scope: summary` (see `git log --oneline`).
  E.g. `secrets: gate agenix-rekey behind my.secrets.enable`.
- Do NOT push or open a PR unless the operator instructed it.

## Steps

### Step 1: Wrap the config block in `mkIf`

In `modules/nixos/secrets/default.nix`, change `config = {` to
`config = mkIf cfg.enable {`. `mkIf` is already in scope via the file's
`with lib;` on line 7.

**Verify**: `grep -n 'config = mkIf cfg.enable' modules/nixos/secrets/default.nix`
→ one match.

### Step 2: Remove the dummy pubkey fallback

Delete the `dummyPubkey` binding (line 13) and remove the
`default = dummyPubkey;` line from the `sshKey` option, so that a host which
enables secrets but forgets to set a pubkey fails loudly at evaluation instead
of silently encrypting to a known key.

The `sshKey` option should keep its `type`, `description`, and `example` and
simply have no `default`.

**Verify**: `grep -rn 'dummyPubkey\|age1qyqszqgp' modules/` → no matches.

### Step 3: Confirm both hosts still evaluate and baldon is no longer a rekey target

```
nix eval .#nixosConfigurations.rome.config.system.build.toplevel.drvPath
nix eval .#nixosConfigurations.baldon.config.system.build.toplevel.drvPath
```

Both must exit 0.

Then confirm baldon no longer carries a rekey pubkey:

```
nix eval --raw .#nixosConfigurations.baldon.config.age.rekey.hostPubkey
```

**Expected**: this should now either error (option has no value) or return an
empty/unset result — it must NOT return the `age1qyqszqgp...` dummy string.
An error here is the *success* case; note which it is in your report.

If `rome` fails to evaluate, that is a STOP condition — `rome` sets both
`enable` and `sshKey`, so it must keep working.

### Step 4: Format

Run `nix fmt` and confirm the tree is clean afterwards.

**Verify**: `nix fmt && git diff --exit-code -- modules/nixos/secrets/default.nix`
→ after your intended edits are committed, a second `nix fmt` produces no diff.

## Test plan

No unit tests exist for NixOS modules in this repo; evaluation is the gate.

- Both host evaluations above must pass — this is the regression test.
- Additionally verify `rome` still has the real pubkey wired:
  `nix eval --raw .#nixosConfigurations.rome.config.age.rekey.hostPubkey`
  → must print the `ssh-ed25519 AAAAC3...` value from
  `configurations/nixos/rome/default.nix:46`, unchanged.

## Done criteria

ALL must hold:

- [ ] `grep -n 'config = mkIf cfg.enable' modules/nixos/secrets/default.nix` → one match
- [ ] `grep -rn 'dummyPubkey\|age1qyqszqgp' modules/` → no matches
- [ ] `nix eval .#nixosConfigurations.rome.config.system.build.toplevel.drvPath` exits 0
- [ ] `nix eval .#nixosConfigurations.baldon.config.system.build.toplevel.drvPath` exits 0
- [ ] `nix eval --raw .#nixosConfigurations.rome.config.age.rekey.hostPubkey` prints the ed25519 key, not a dummy
- [ ] `nix fmt` produces no further diff
- [ ] No files outside `modules/nixos/secrets/default.nix` are modified (`git status`)
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report back (do not improvise) if:

- `rome` fails to evaluate after the change.
- Removing the `default` causes an evaluation error on a host *other* than
  through the expected "option not set" path — e.g. if agenix-rekey requires
  `hostPubkey` to be defined even when the rest of the config is gated.
- You find a third NixOS host beyond `rome` and `baldon` (the working tree has
  in-flight deletions of `aerial` and `gleba`; if they reappear, re-scope).
- Any change appears to require editing `secrets/` — always a STOP.

## Maintenance notes

- After this lands, adding a new NixOS host that needs secrets requires
  **both** `my.secrets.enable = true` and `my.secrets.sshKey = "<host pubkey>"`.
  Forgetting the pubkey is now an eval error, which is the intended behavior.
- A reviewer should confirm that `baldon` was not "fixed" by enabling secrets on
  it — the correct outcome is that baldon opts out entirely.
- Related: `modules/nixos/secrets/default.nix:47` uses a single master identity
  (`secrets/master-keys/yubikey-c.age`). That single point of failure is not
  addressed here; it is covered as a documentation item in plan 005.
