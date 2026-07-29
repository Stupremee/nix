# Plan 005: Write the bootstrap, recovery, and conventions documentation

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 3327631..HEAD -- README.md modules/flake/devshell.nix`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- **Priority**: P2
- **Effort**: M
- **Risk**: LOW
- **Depends on**: none
- **Category**: docs
- **Planned at**: commit `3327631`, 2026-07-29

## Why this matters

`README.md` is one line: `# NixOS configuration`. There is no `CLAUDE.md`, no
`AGENTS.md`, no `docs/`.

Meanwhile the undocumented prerequisites are substantial and the failure mode is
severe: `modules/nixos/secrets/default.nix:47` sets
`masterIdentities = [ ../../../secrets/master-keys/yubikey-c.age ]` — a **single**
master identity. If that one YubiKey is lost, every encrypted file under
`secrets/` becomes permanently unrecoverable. Nothing in the repo says this, and
nothing says how to add a second recipient before that happens.

Beyond disaster recovery, the repo has strong conventions that exist only in the
author's head: which module argument is `flake` versus `inputs`, the fact that
every module directory is auto-imported into every host, and that adding an
`.age` secret requires a manual rekey step. Any contributor — human or agent —
will guess wrong on at least one, and with no CI (see plan 004) those guesses
surface at deploy time.

## Current state

`README.md` in full:

```markdown
# NixOS configuration
```

The facts you will need to write the docs, gathered from the repo — **verify
each one yourself before writing it down**:

**Layout**
- `configurations/nixos/<host>/` — NixOS hosts. Currently `rome` (server) and
  `baldon` (desktop). The working tree has uncommitted deletions of `aerial`
  and `gleba`.
- `configurations/darwin/<host>.nix` — nix-darwin hosts. Currently
  `MacBook-Pro-von-Justus.nix`.
- `configurations/home/<name>.nix` — home-manager configs, named either
  `<user>.nix` or `<user>@<host>.nix`. The selection logic is at
  `modules/nixos/user/default.nix:67-80`.
- `modules/{nixos,home,darwin}/<name>/default.nix` — feature modules, each
  declaring `my.<name>.enable`.
- `packages/`, `overlays/` — custom derivations and the nixpkgs overlay.
- `secrets/` — agenix-encrypted files; `secrets/rekeyed/` and
  `secrets/generated/` are machine-generated, never hand-edited.

**The auto-import mechanism** — `modules/nixos/default.nix:7-15`:

```nix
  imports =
    with flake.inputs;
    [
      disko.nixosModules.default
      impermanence.nixosModules.default
      agenix.nixosModules.default
      agenix-rekey.nixosModules.default
    ]
    ++ (attrValues (filterAttrs (name: _: name != "default") flake.inputs.self.nixosModules));
```

Every module in `modules/nixos/` is imported into every NixOS host. The same
pattern applies in `modules/home/default.nix:16` and `modules/darwin/default.nix:9`.
Consequence: adding a directory changes the option surface of every host, and a
module's `config` block must be gated behind `mkIf cfg.enable` or it applies
everywhere.

**Module arguments**: NixOS/home/darwin modules receive `flake` (verified:
`nixosConfigurations.rome._module.specialArgs` is `[ "flake" "modulesPath" ]`).
Flake-parts modules under `modules/flake/` receive `inputs`. Mixing them up is
an eval error. Note that `modules/nixos/server/default.nix` and
`modules/nixos/paperless/default.nix` currently declare an `inputs` argument
that is never provided — it works only because it is never used.

**Deploy**: `nixos-unified` provides `nix run .#activate`. Remote target is set
per-host, e.g. `configurations/nixos/rome/default.nix:20`:
`nixos-unified.sshTarget = "stu@rome";`. The devshell exposes
`just activate`, `just check`, `just fmt` — defined as a string inside
`modules/flake/devshell.nix:18-30`, not in the root `justfile`.

**Secrets flow**: a secret is declared in a module as
`age.secrets.<name>.rekeyFile = ../../../secrets/<file>.age;`, then rekeyed to
the host with the `agenix` CLI from the devshell (`modules/flake/devshell.nix:39-42`
puts `agenix-rekey` and `age-plugin-yubikey` on PATH). Generated secrets use
`generator.script = "alnum"` instead of a `rekeyFile` — see
`modules/nixos/oidc/default.nix:78-81`.

**Manual out-of-band steps** that no Nix code performs:
- Homebrew must be installed by hand on the darwin host before activation
  (`configurations/darwin/MacBook-Pro-von-Justus.nix:44-49` configures it but
  nix-darwin does not install it).
- `configurations/darwin/MacBook-Pro-von-Justus.nix:51` hardcodes
  `nix.settings.builders = "ssh://root@rome x86_64-linux"`, so the Mac needs
  working root SSH access to `rome` to build Linux derivations.

## Commands you will need

| Purpose | Command | Expected on success |
|---|---|---|
| Verify a claim about options | `nix eval --json .#nixosConfigurations.rome.config.<path>` | prints the value |
| List flake outputs | `nix flake show` | tree of outputs |
| Check devshell recipes | `nix develop -c just --list` | lists activate/check/fmt |
| Format | `nix fmt` | exit 0 |

Markdown is excluded from treefmt (`modules/flake/treefmt.nix:24` excludes
`README.md`), so formatting will not rewrite your prose.

## Scope

**In scope**:
- `README.md` (rewrite)
- `CLAUDE.md` (create)
- `docs/bootstrap.md` (create, if README grows past ~150 lines — otherwise keep
  it all in README)

**Out of scope** (do NOT touch):
- Any `.nix` file. This plan is documentation only. If you find something
  broken while writing, record it in your report — do not fix it.
- `secrets/**` — never read, never edit.
- `plans/**` other than the status row in `plans/README.md`.

## Git workflow

- Branch: `advisor/005-docs`
- Commit message e.g. `docs: add bootstrap, recovery and conventions guide`.
- Do NOT push or open a PR unless the operator instructed it.

## Steps

### Step 1: Verify every factual claim before writing it

For each fact listed in "Current state" above, confirm it against the live repo.
Specifically run:

```
nix flake show
nix develop -c just --list
grep -rn 'sshTarget' configurations/
nix eval --json .#nixosConfigurations.rome._module.specialArgs --apply 'builtins.attrNames'
```

**Verify**: you have first-hand confirmation for each claim you intend to write.
Anything you cannot confirm must be written as an open question in the doc
(a `> **TODO(operator)**:` callout), not stated as fact.

### Step 2: Write `README.md`

Structure it as:

1. **What this is** — one paragraph: a flake-based config for N hosts, built on
   flake-parts + `srid/nixos-unified`, with agenix-rekey secrets.
2. **Hosts** — a table: name, platform, role, deploy target. Fill from
   `configurations/`.
3. **Layout** — the directory map from "Current state", including the
   auto-import behavior and its consequence.
4. **Daily operations** — deploy (`just activate` / `nix run .#activate`),
   update inputs, format, check.
5. **Secrets** — the agenix-rekey model, how to add a secret, how to rekey,
   and the `rekeyFile` vs `generator.script` distinction.
6. **Bootstrapping a new host** — pubkey generation and registration, first
   rekey, first activation; note that `rome` uses disko for partitioning while
   `baldon` has hand-written `fileSystems` with hardcoded UUIDs.
7. **Prerequisites and manual steps** — Homebrew on darwin, root SSH to rome
   for the remote builder, YubiKey + `age-plugin-yubikey` from the devshell.

### Step 3: Write the disaster-recovery section — this is the point of the plan

Add a clearly-marked section covering:

- **The single-master-identity risk**: `secrets/master-keys/yubikey-c.age` is the
  only master identity. Losing that YubiKey means every secret is unrecoverable.
- **The recommended mitigation**: add a second master identity (a backup
  YubiKey, or an age identity stored offline) to
  `age.rekey.masterIdentities` in `modules/nixos/secrets/default.nix` and
  re-run the rekey, so secrets are encrypted to both.
- **What to do if the key is lost**: enumerate which secrets can be regenerated
  from scratch (the `generator.script = "alnum"` ones — Authelia's JWT, HMAC,
  session, and storage-encryption secrets; the paperless and MQTT passwords)
  versus which must be re-obtained from a third party (the Cloudflare tokens
  and certificate, the restic repository password — losing that one means the
  backups are unreadable).

Write this as an actionable checklist, not prose.

**Do not put any credential value in the documentation.** Reference file paths
and credential types only.

### Step 4: Write `CLAUDE.md`

A short (~40-60 line) conventions file for agents and future-you. Cover:

- The module template: `options.my.<name>.enable = mkEnableOption "...";` plus
  `config = mkIf cfg.enable { ... };`, with a pointer to
  `modules/nixos/openssh/default.nix` as the exemplar.
- The auto-import glob and why `mkIf` is mandatory.
- `flake` vs `inputs` module arguments, and which class gets which.
- Run `nix fmt` before committing; treefmt covers Nix and shell only.
- The eval gate: `nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath`.
- Never hand-edit `secrets/rekeyed/` or `secrets/generated/`; adding an `.age`
  secret requires a rekey.
- Commit message style: terse `scope: summary` (cite two real examples from
  `git log --oneline`).

### Step 5: Verify the docs are accurate and links resolve

Re-read what you wrote against the repo one final time. Then check every file
path mentioned in the docs actually exists:

```
grep -oE '`[a-zA-Z0-9_./@-]+\.(nix|md|sh|toml|yaml)`' README.md CLAUDE.md \
  | tr -d '`' | sed 's/^[^:]*://' | sort -u \
  | while read -r f; do [ -e "$f" ] || echo "MISSING: $f"; done
```

**Verify**: no `MISSING:` lines. (Paths inside prose that refer to files created
by future plans are acceptable — if any appear, mark them explicitly in the
doc as not-yet-existing.)

## Test plan

Documentation has no automated tests. The verification is:

- Every file path referenced in the docs exists (Step 5's check).
- Every command quoted in the docs was actually run in Step 1 and produced the
  described result.
- Any claim that could not be verified appears as a `TODO(operator)` callout
  rather than as an assertion.

## Done criteria

ALL must hold:

- [ ] `README.md` is more than 100 lines and contains sections for hosts,
      layout, deploy, secrets, bootstrap, and prerequisites
- [ ] `README.md` contains a disaster-recovery section that names the
      single-master-identity risk and the mitigation
- [ ] `CLAUDE.md` exists and documents the module template, the auto-import
      glob, and the `flake` vs `inputs` distinction
- [ ] Step 5's path check produces no `MISSING:` lines
- [ ] No `.nix` file is modified (`git status` shows only `README.md`,
      `CLAUDE.md`, optionally `docs/`, and `plans/README.md`)
- [ ] No credential values appear anywhere in the new files
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report back (do not improvise) if:

- A fact in "Current state" turns out to be false — report the discrepancy
  rather than documenting your guess.
- You cannot determine the bootstrap sequence for a new host with enough
  confidence to write it down. A partial doc with explicit `TODO(operator)`
  gaps is the correct output; an invented procedure is not.
- You find yourself wanting to change a `.nix` file to make the docs true —
  that is a separate plan.
- You discover credentials in a file you were reading — stop, report the
  location and type only, and do not quote the value.

## Maintenance notes

- The host table and the layout section will drift as hosts are added or
  removed. The in-flight `aerial`/`gleba` deletions are a live example — write
  the docs against the current tree and note the deletions are uncommitted.
- **The highest-value follow-up from this plan is not documentation**: actually
  adding a second master identity so the YubiKey stops being a single point of
  failure. This plan documents the risk and the procedure; someone still has to
  perform it.
- A reviewer should check the disaster-recovery checklist against reality by
  mentally walking a "rome's disk died" scenario and looking for gaps.
