# Nix deployment

Run deployment commands from the repository root.

- `nix run .#` builds and activates the configuration for the current machine.
- `nix run .# -- rome` builds and activates Rome. It uses SSH when run from
  another machine and activates locally when run on Rome.

After changing a host's Nix configuration, deploy that host with the matching
command and verify the affected service and endpoint. Report deployment failures
with the failing command and the relevant error output.
