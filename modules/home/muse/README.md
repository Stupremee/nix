# Muse Code through CLIProxyAPI

Enable `my.muse.enable` in the host's Home Manager configuration.

The module manages the Muse launcher wrapper, Varlock, the CLIProxyAPI endpoint,
and four Contributor models with readable names. Wonder Full 1.0 Contributor is
the default. Activation merges these settings into Muse's mutable `settings.json`
and preserves other preferences.

The official Muse launcher must be installed at `~/.local/bin/muse-upstream`.
It continues to manage Muse binary updates.

Varlock reads the existing CLIProxyAPI client key from
`~/.claude/settings.json` when Muse starts. The resolver requires the configured
Claude endpoint to use HTTPS and the hostname `cliproxy.jukl.dev`.
Keep credentials in the local configuration. The Nix module contains only the
credential reference.
