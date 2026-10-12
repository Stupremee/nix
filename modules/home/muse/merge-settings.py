#!/usr/bin/env python3
"""Merge Nix-owned Muse settings while preserving other preferences."""

import fcntl
import json
import os
import stat
import sys
import tempfile
from pathlib import Path


def main() -> None:
    profile_path, settings_path = map(Path, sys.argv[1:])
    profile = json.loads(profile_path.read_text())
    settings_path.parent.mkdir(parents=True, exist_ok=True)
    with settings_path.with_name(".settings.json.lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        settings = json.loads(settings_path.read_text()) if settings_path.exists() else {}
        if not isinstance(settings, dict):
            sys.exit("Muse settings must contain a JSON object.")
        merged = settings | profile
        if merged == settings:
            return
        mode = stat.S_IMODE(settings_path.stat().st_mode) if settings_path.exists() else 0o600
        fd, temporary = tempfile.mkstemp(prefix=".settings.json.", dir=settings_path.parent)
        try:
            with os.fdopen(fd, "w") as output:
                json.dump(merged, output, indent=2)
                output.write("\n")
            os.chmod(temporary, mode)
            os.replace(temporary, settings_path)
        finally:
            if os.path.exists(temporary):
                os.unlink(temporary)


if __name__ == "__main__":
    main()
