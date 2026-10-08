# Plan 006: Proton Mail account for postbote on rome

> **Executor instructions**: Work on branch `postbote` (worktree `~/nix-postbote` on aerial, or
> check it out). Steps marked **[Stu]** need Stu (interactive Proton login, YubiKey); stop there,
> hand over the exact commands, and continue once he confirms. Deploy with `nix run .# -- rome`
> and verify each step before the next. Update the status row in `plans/README.md` when done.

## Status

- **Priority**: P2
- **Effort**: S
- **Depends on**: none
- **Planned at**: branch `postbote` @ `dc6b8bd`, 2026-10-08

## Context

- postbote (mail MCP server, `Stupremee/postbote`) runs on rome via `modules/nixos/postbote/`,
  public at `https://postbote.jukl.dev/mcp`, currently with **zero accounts**. Module docs:
  postbote repo `nix/README.md` and `README.md`.
- PR Stupremee/postbote#1 is merged into `main` (squash `197c13e`). The flake input still
  points at `ref=feat/v1`. postbote v2 (labels, structured data, calendar, sending with
  approval, metrics) is on `feat/v2` and will be merged to `main` too; take `main` then.
- Sign-in is via one-time pairing codes: `sudo postbote-ctl pair` on rome.
- rome: lingering for `stu` is on, `stu` has one GPG secret key, `pass` is installed but **not
  initialised** (`~/.local/share/password-store` has no `.gpg-id`).

## Steps

### 1. Point the postbote input at `main`

- `flake.nix`: `postbote.url = "git+ssh://git@github.com/Stupremee/postbote?ref=main"`.
- `nix flake update postbote`; the locked rev must be `197c13e…` or newer on `main`.
- Check `nix store diff-closures` between the current rome system and the new build shows no
  postbote change (the squash has the same tree as the deployed `feat/v1` head `2f24e18`).
- Commit. Then Stu may delete the `feat/v1` branch.

### 2. Run Proton Bridge as a headless user service

- Enable `services.protonmail-bridge` (NixOS module, user service) on rome only.
- The module binds the unit to `graphical-session.target`, which never starts on a headless
  host. Override: `systemd.user.services.protonmail-bridge.wantedBy = lib.mkForce [ "default.target" ];`
  and `after = lib.mkForce [ ];`.
- Bridge keeps its vault key in a keychain; on Linux it uses `pass`. Put `pkgs.pass` and
  `pkgs.gnupg` in `services.protonmail-bridge.path`.
- Bridge listens on `127.0.0.1:1143` (IMAP, STARTTLS) and `127.0.0.1:1025` (SMTP, unused).
  Loopback only, no firewall change.
- Put this in a small module `modules/nixos/protonmail-bridge/` with `my.protonmail-bridge.enable`,
  following the repo's module style. Persistence: Bridge state lives in `/home/stu`
  (`~/.config/protonmail`, `~/.local/share/protonmail`, `~/.cache/protonmail`); check whether
  `/home` is already persistent on rome before adding anything.
- Deploy. The service will fail until step 3; that is expected.

### 3. **[Stu]** Initialise pass and log in to Bridge

On rome as `stu`:

```sh
gpg --list-secret-keys --keyid-format long      # pick the key id
pass init <key-id>
systemctl --user stop protonmail-bridge
protonmail-bridge --cli
  >>> login        # Proton password + 2FA
  >>> info         # note IMAP username and the generated Bridge password
  >>> cert export  # writes cert.pem (and key.pem); keep only cert.pem
  >>> exit
systemctl --user start protonmail-bridge
```

The Bridge password from `info` is not the Proton password. Delete the exported `key.pem`.

### 4. Secret and pinned certificate

- Add the Bridge certificate as `modules/nixos/postbote/proton-bridge-cert.pem` (public, fine
  in git). postbote pins it via `imap.pinnedCertFile`.
- **[Stu]** Create the secret with the Bridge password: `secrets/postbote-proton-imap.age`, then
  `agenix rekey -a` (YubiKey) and commit `secrets/rekeyed/rome`.
- Declare `age.secrets.postbote-proton-imap.rekeyFile = ../../../secrets/postbote-proton-imap.age;`
  with `owner = "root"` (systemd reads it for `LoadCredential`; postbote never needs file access).

### 5. Add the account

In `modules/nixos/postbote/default.nix`:

```nix
services.postbote.accounts.proton = {
  imap = {
    host = "127.0.0.1";
    port = 1143;
    security = "starttls";
    pinnedCertFile = ./proton-bridge-cert.pem;
    username = "<IMAP username from Bridge info>";
    passwordFile = config.age.secrets.postbote-proton-imap.path;
  };
  permissions = [ "read" "draft" "organize" ];
  index = {
    since = "2023-01-01";
    # Bridge exposes "All Mail" and every label as a folder; indexing them duplicates mail.
    excludeFolders = [ "All Mail" "Labels/*" "Spam" "Trash" ];
  };
};
```

- `fromAddress` is only needed if the Bridge IMAP username is not an email address.
- Leave out `webhooks` until there is a fixed receiver URL (`webhooks.allowedTargetsFile`).
- The postbote service must start after Bridge is reachable; it retries on its own, so no
  ordering is required.

### 6. Deploy and verify

- `nix run .# -- rome`.
- `sudo postbote-ctl doctor`: IMAP login OK, capabilities listed, folders without `All Mail` and
  labels, import progressing. The first import of a large mailbox takes a while; tools report
  "mailbox is still being imported" meanwhile.
- `journalctl -u postbote` shows no repeated errors.
- **[Stu]** `sudo postbote-ctl pair`, add the connector `https://postbote.jukl.dev/mcp` in
  claude.ai or Claude Code, paste the code, pick `proton`. Try a search, then a test send to
  Stu's own address and approve it from the Pushover link.

### 7. Merge to master

Rebase `postbote` onto `origin/master`, then merge into `master`, so a deploy from another
machine keeps postbote. Update `plans/README.md`.

## STOP conditions

- Bridge cannot keep its login across a restart (check after `systemctl --user restart`):
  report, do not work around with plaintext keychains.
- `doctor` shows a TLS or pinning error: report the exact error; do not disable pinning.
- A test send (draft to Stu's own address, `request_send`, approve) does not arrive, or arrives
  with content different from the approval page: stop and report.
- Anything in the diff-closures of step 1 or 2 touches services other than postbote, Bridge and
  the tunnel.
