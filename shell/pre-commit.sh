#!/usr/bin/env bash

# Script that will format all staged files
# using nixpkgs-fmt

git="$(nix-build '<nixpkgs>' -A git)/bin/git"
fmt="$(nix-build '<nixpkgs>' -A nixpkgs-fmt)/bin/nixpkgs-fmt"
rg="$(nix-build '<nixpkgs>' -A ripgrep)/bin/rg"

if $git rev-parse --verify HEAD > /dev/null 2>&1
then
  target=HEAD
else
  # There is no commit in this repository yet,
  # so check against the empty tree.
  target="$($git hash-object -t tree /dev/null)"
fi

exec 1>&2

files="$($git diff-index --name-only --cached $target | $rg '\.nix$')"
exec $fmt $files
