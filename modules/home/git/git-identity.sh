#!/usr/bin/env bash

# get each set of usernames from the git config (which will be generated from our `default.nix` above)
IDENTITIES=$(git config --global --name-only --get-regexp "user.*..name" | sed -e 's/^user.//' -e 's/.name$//')

# filter them with fzf
ID=$(echo "${IDENTITIES}" | fzf -e -1 +m -q "$1")
if ! git config --global --get-regexp "user.${ID}.name" >/dev/null; then
  echo "Please use a valid git identity
Options:"
  git config --global --name-only --get-regexp "user.*..name" | sed -e 's/^user.//' -e 's/.name$//' -e 's/^/\t/'
  exit 1
fi

# set the ID locally in each repo (eg in the repo's .git/config)
git config user.name "$(git config user.${ID}.name)"
git config user.email "$(git config user.${ID}.email)"
git config user.signingkey "$(git config user.${ID}.signingKey)"

echo "Name: $(git config user.name)"
echo "Email: $(git config user.email)"
echo "Signing Key: $(git config user.signingkey)"
