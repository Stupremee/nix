# Plan 004: Establish a verification baseline — green tests, real flake checks, and CI

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 3327631..HEAD -- packages/sunspec-modbus-server modules/flake/toplevel.nix`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- **Priority**: P1
- **Effort**: M
- **Risk**: MED
- **Depends on**: none (but should land before plans that change behavior)
- **Category**: tests
- **Planned at**: commit `3327631`, 2026-07-29

## Why this matters

There is currently no way to know this repo works before deploying it.

- The only unit-tested code — the SunSpec Modbus server that drives a real heat
  pump — has `doCheck = false`, so its five test files never run. Three of those
  tests are **currently failing** (the assertions disagree with the code's
  export formula), which is presumably why checks were disabled.
- `nix flake check` reports only one check: `treefmt`. The `darwinConfigurations`
  output is not a Nix-known output and is skipped, and all three home-manager
  configurations live under `legacyPackages`, which `nix flake check` explicitly
  skips. So an eval error on the MacBook or in any home module is discovered at
  deploy time.
- There is no CI. `.github/` has never existed on any branch.

Every other plan in this directory changes behavior on a machine that controls
a heat pump, an identity provider, and a document archive. This plan is the
prerequisite that makes those changes verifiable.

## Current state

`packages/sunspec-modbus-server/default.nix` in full:

```nix
{
  lib,
  python3Packages,
}:
python3Packages.buildPythonApplication {
  pname = "sunspec-modbus-server";
  version = "0.1.0";
  pyproject = true;

  src = ./.;

  doCheck = false;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    aiohttp
    pymodbus
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "sunspec_modbus_server"
  ];
}
```

Note `pytestCheckHook` is already declared — it is simply never run.

**The failing tests.** The code at
`packages/sunspec-modbus-server/src/sunspec_modbus_server/grid_export_simulation.py:74`:

```python
        simulated_export_w = max(max(0.0, values["pv_power_w"]) * 2.0, 10000.0)
```

That is `max(pv * 2, 10000)` — a 10 kW floor. The tests at
`packages/sunspec-modbus-server/tests/test_grid_export_simulation.py:45-59`
expect no floor:

```python
def test_simulation_activates_when_conditions_match() -> None:
    simulator = make_simulator()
    effective = simulator.apply(make_values())

    assert simulator.active is True
    assert effective["grid_power_w"] == -8000.0


def test_simulation_subtracts_virtual_export_from_real_meter_value() -> None:
    simulator = make_simulator()
    effective = simulator.apply(make_values(grid_power_w=750.0))

    assert simulator.active is True
    assert effective["grid_power_w"] == -7250.0
    assert effective["pv_power_w"] == 12000.0
```

With `pv_power_w = 4000` (check the `make_values` fixture to confirm), the code
produces `max(8000, 10000) = 10000`, so `grid_power_w` becomes `-10000.0`, not
`-8000.0`. A third test at `test_grid_export_simulation.py:145` has the same
mismatch on the decoded meter register.

The package README (`packages/sunspec-modbus-server/README.md`, around lines
83-85) documents the behavior as `real_grid_power_w - (2 * pv_power_w)` — with
**no** mention of the 10 kW floor. So the README and the tests agree with each
other, and the code disagrees with both.

**Which is correct is a judgment call you must not make alone** — see Step 2.

`modules/flake/toplevel.nix` (current, 36 lines) — note it defines
`packages.sunspecModbusServer` by hand while autoWire already produces
`packages.sunspec-modbus-server` from the `packages/` directory:

```nix
  perSystem =
    {
      self',
      pkgs,
      ...
    }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        localSystem = pkgs.stdenv.hostPlatform;
        config = { };
      };
      # Enables 'nix run' to activate.
      packages.default = self'.packages.activate;
      packages.sunspecModbusServer = pkgs.callPackage ../../packages/sunspec-modbus-server { };
```

## Commands you will need

| Purpose | Command | Expected on success |
|---|---|---|
| Build the package (runs tests once enabled) | `nix build .#sunspec-modbus-server -L` | exit 0 |
| Run tests directly | `nix develop -c pytest packages/sunspec-modbus-server/tests -q` | see Step 1 |
| List flake checks | `nix eval .#checks --apply 'builtins.mapAttrs (_: builtins.attrNames)' --json` | JSON of check names |
| Flake check | `nix flake check --no-build` | exit 0 |
| Format | `nix fmt` | exit 0 |

## Scope

**In scope**:
- `packages/sunspec-modbus-server/default.nix`
- `packages/sunspec-modbus-server/tests/test_grid_export_simulation.py` **or**
  `packages/sunspec-modbus-server/src/sunspec_modbus_server/grid_export_simulation.py`
  (exactly one of these — see Step 2)
- `packages/sunspec-modbus-server/pyproject.toml`
- `modules/flake/toplevel.nix`
- `.github/workflows/check.yml` (create)

**Out of scope** (do NOT touch, even though they look related):
- Any other Python source file in the package. The NaN-handling bug, the scale
  factor bugs, and the stale-data handling are real but are separate findings
  with their own risk profile — fixing them here would mean this plan changes
  heat-pump behavior, which defeats its purpose as a *baseline*.
- `packages/sunspec-modbus-server/README.md` — update it only if Step 2
  resolves in favor of the tests; otherwise leave it.
- All `modules/nixos/**` — other plans own those.

## Git workflow

- Branch: `advisor/004-verification-baseline`
- Commit per step; terse `scope: summary` messages, e.g.
  `sunspec: enable tests in nix build`.
- Do NOT push or open a PR unless the operator instructed it.

## Steps

### Step 1: Confirm the failure before changing anything

Run the tests as they stand to see the actual failures:

```
nix develop -c pytest packages/sunspec-modbus-server/tests -q
```

If the package cannot be imported (the `src/` layout may need
`pythonpath`), add to `packages/sunspec-modbus-server/pyproject.toml` under
`[tool.pytest.ini_options]`:

```toml
pythonpath = ["src"]
```

**Verify**: pytest runs and reports exactly 3 failures, all in
`test_grid_export_simulation.py`. Record the exact assertion diffs.

If you see a different number of failures, that is important information — record
it, and continue only if the extra failures are also in that file. Failures in
other test files are a STOP condition.

### Step 2: Resolve the code-vs-tests disagreement — ASK, do not guess

The 10 kW floor at `grid_export_simulation.py:74` either is a deliberate
behavior added after the tests were written, or is a leftover debugging value.
The README agrees with the tests, not the code.

**This is a behavior decision about a device that heats a house. Do not decide
it yourself.** Report both options to the operator and wait:

- **Option A** — the floor is intentional: update the three test assertions to
  expect `-10000.0` / `-9250.0` / `14000.0` / `-10000` respectively, and update
  `README.md` to document the floor.
- **Option B** — the floor is a leftover: change line 74 to
  `simulated_export_w = max(0.0, values["pv_power_w"]) * 2.0` and leave the
  tests and README as they are.

If the operator is unavailable, **default to Option A** (make the tests match
the deployed code) — it is the choice that does not alter what the heat pump
currently sees. Record clearly in your report that you did so and that the
behavior question is still open.

**Verify**: `nix develop -c pytest packages/sunspec-modbus-server/tests -q` → all pass.

### Step 3: Enable checks in the Nix build

In `packages/sunspec-modbus-server/default.nix`, remove the `doCheck = false;`
line. `pytestCheckHook` is already in `nativeCheckInputs`, so tests will run
automatically.

Also strengthen the vacuous import check — `src/sunspec_modbus_server/__init__.py`
imports nothing, so the current `pythonImportsCheck` would pass even if every
pymodbus symbol had been removed. Extend it:

```nix
  pythonImportsCheck = [
    "sunspec_modbus_server"
    "sunspec_modbus_server.modbus_server"
    "sunspec_modbus_server.register_store"
  ];
```

**Verify**: `nix build .#sunspec-modbus-server -L` → exit 0, and the build log
shows pytest running and passing.

### Step 4: Remove the duplicate package definition

In `modules/flake/toplevel.nix`, delete the line:

```nix
      packages.sunspecModbusServer = pkgs.callPackage ../../packages/sunspec-modbus-server { };
```

autoWire already produces `packages.sunspec-modbus-server` from the `packages/`
directory, and the hand-written one builds against a different `pkgs` (the one
defined at `toplevel.nix:15-18` with `config = { }`), producing a second store
path from the same source.

**Before deleting**, confirm nothing references the camelCase name:

```
grep -rn 'sunspecModbusServer' --include='*.nix' . | grep -v '\.direnv'
```

Expect hits in `modules/nixos/sunspec-modbus-server/default.nix` (the
`services.sunspecModbusServer` option path — a *different* thing, do not touch)
and possibly `overlays/default.nix`. If `overlays/default.nix` defines
`sunspecModbusServer`, that is the overlay attribute the NixOS module consumes
via `pkgs.sunspecModbusServer` — **leave the overlay alone**, only remove the
`packages.` output in `toplevel.nix`.

**Verify**:
- `nix eval .#packages.x86_64-linux --apply 'builtins.attrNames' --json` → contains
  `sunspec-modbus-server`, no longer contains `sunspecModbusServer`.
- `nix eval .#nixosConfigurations.rome.config.system.build.toplevel.drvPath` → exits 0.

### Step 5: Add flake checks for the configurations that `nix flake check` skips

In `modules/flake/toplevel.nix`, inside `perSystem`, add a `checks` attrset that
exposes the darwin and home-manager configurations as buildable checks, so
`nix flake check` actually evaluates them.

The shape (adapt names to what actually exists — verify with
`nix flake show` first):

```nix
      checks = {
        darwin-macbook = self.darwinConfigurations."MacBook-Pro-von-Justus".system;
        home-stu = self.legacyPackages.${system}.homeConfigurations."stu".activationPackage;
      };
```

You will need `self` and `system` in scope — check how other `perSystem` blocks
in this repo access them (`self'` is already used at `toplevel.nix:20`).

**Important**: darwin checks only make sense on `aarch64-darwin` and NixOS
checks on `x86_64-linux`. Guard each entry with a system check, e.g. using
`lib.optionalAttrs (system == "aarch64-darwin")`, so `nix flake check` on Linux
does not try to evaluate a darwin config.

If the exact attribute paths do not resolve, run `nix flake show` and read the
actual output tree rather than guessing.

**Verify**:
```
nix eval .#checks --apply 'builtins.mapAttrs (_: builtins.attrNames)' --json
```
→ shows more than just `treefmt` for at least one system.

### Step 6: Add CI

Create `.github/workflows/check.yml` running on push and pull_request:

- Use `DeterminateSystems/nix-installer-action` (or `cachix/install-nix-action`)
  and `DeterminateSystems/magic-nix-cache-action`.
- Job 1 on `ubuntu-latest`: `nix flake check --no-build` and
  `nix build .#sunspec-modbus-server`.
- Job 2 on `macos-latest`: `nix flake check --no-build`.

Keep it minimal — evaluation and the one buildable package. Do **not** try to
build full NixOS system closures in CI; that is slow and needs the rome builder.

**Verify**: `test -f .github/workflows/check.yml` → exit 0, and the YAML parses:
`nix run nixpkgs#yq -- . .github/workflows/check.yml > /dev/null` → exit 0.

### Step 7: Add a `test` recipe to the devshell

In `modules/flake/devshell.nix`, add to the `just-flake.features.flake.justfile`
string:

```
            # Run the python test suite
            test:
              nix build .#sunspec-modbus-server -L
```

**Verify**: `nix develop -c just --list` → shows `test` alongside
`activate`, `check`, `fmt`.

## Test plan

- The three currently-failing tests in
  `packages/sunspec-modbus-server/tests/test_grid_export_simulation.py` must pass
  after Step 2, whichever option was chosen.
- No new tests are written in this plan. Writing tests for the untested risky
  paths (the Home Assistant client's error handling, register scale-factor
  round-trips) is deliberately deferred — this plan's job is to make the
  existing suite run, not to expand it.
- Verification: `nix build .#sunspec-modbus-server -L` → exit 0 with pytest
  passing in the log; `nix flake check --no-build` → exit 0.

## Done criteria

ALL must hold:

- [ ] `grep -n 'doCheck' packages/sunspec-modbus-server/default.nix` → no matches
- [ ] `nix build .#sunspec-modbus-server -L` exits 0 and the log shows pytest passing
- [ ] `nix eval .#packages.x86_64-linux --apply 'builtins.attrNames' --json` no longer contains `sunspecModbusServer`
- [ ] `nix eval .#checks --apply 'builtins.mapAttrs (_: builtins.attrNames)' --json` lists more than `treefmt`
- [ ] `nix flake check --no-build` exits 0
- [ ] `.github/workflows/check.yml` exists and is valid YAML
- [ ] `nix eval .#nixosConfigurations.rome.config.system.build.toplevel.drvPath` exits 0
- [ ] `nix fmt` produces no further diff
- [ ] `plans/README.md` status row updated, and the Step 2 decision recorded there

## STOP conditions

Stop and report back (do not improvise) if:

- Step 1 reveals failures outside `test_grid_export_simulation.py`.
- The operator is reachable and has not answered the Step 2 question — wait
  rather than defaulting.
- Enabling `doCheck` surfaces a test that fails non-deterministically (a flaky
  test) — report it rather than adding `disabledTests`.
- Step 5's attribute paths do not resolve after consulting `nix flake show`.
- Removing `packages.sunspecModbusServer` breaks `rome`'s evaluation — that
  would mean the NixOS module consumes the flake output rather than the overlay,
  and the fix needs rethinking.

## Maintenance notes

- Once CI exists, the other plans in this directory become far safer to execute;
  prefer landing this one first.
- **The Step 2 decision is the load-bearing part of this plan.** Whichever way
  it resolves, the README, the tests, and the code must agree afterwards. A
  reviewer should check all three.
- Deliberately deferred: the known correctness bugs in this package (a NaN
  sensor reading clamps to the register maximum rather than being rejected; a
  Home Assistant outage serves stale values indefinitely with no staleness
  signal; several SunSpec scale factors are inconsistent with the values
  written). Each changes what the heat pump sees and deserves its own plan
  with its own rollback story — but they are much easier to write once this
  suite actually runs.
