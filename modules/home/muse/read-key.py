#!/usr/bin/env python3
"""Resolve the existing CLIProxyAPI client key for Varlock."""

import json
import sys
from pathlib import Path
from urllib.parse import urlsplit


def main() -> None:
    try:
        settings = json.loads((Path.home() / ".claude" / "settings.json").read_text())
        provider_env = settings["env"]
        endpoint = urlsplit(provider_env["ANTHROPIC_BASE_URL"])
        if endpoint.scheme != "https" or endpoint.hostname != "cliproxy.jukl.dev":
            raise ValueError("unexpected CLIProxyAPI endpoint")
        key = provider_env["ANTHROPIC_AUTH_TOKEN"]
        if not isinstance(key, str) or not key.strip():
            raise ValueError("CLIProxyAPI client key is missing")
    except (OSError, ValueError, KeyError, TypeError):
        sys.exit("Could not resolve the existing CLIProxyAPI client key.")
    sys.stdout.write(key)


if __name__ == "__main__":
    main()
