# CLIProxyAPI management panel

Rome serves a pinned Management Center build at `/management.html`. The patch adds
OpenCode Go to the native Quota Management tabs and auth file quota cards. Its
browser requests use the existing authenticated plugin management endpoint;
the OpenCode Go API key stays on the server.

The source is [Cli-Proxy-API-Management-Center](https://github.com/router-for-me/Cli-Proxy-API-Management-Center)
at commit `4530da271ba2e89810d4dccebc57f3091afa590a`. The local changes are in
`management-center.patch`; `management.html.gz` is the built single-file panel.

To rebuild after editing the patch:

```sh
git clone https://github.com/router-for-me/Cli-Proxy-API-Management-Center /tmp/cliproxy-management-center
cd /tmp/cliproxy-management-center
git checkout 4530da271ba2e89810d4dccebc57f3091afa590a
git apply /home/stu/dev/nix/modules/nixos/cliproxyapi/management-center.patch
bun install --frozen-lockfile
bun run verify
gzip -n -9 -c dist/index.html > /home/stu/dev/nix/modules/nixos/cliproxyapi/management.html.gz
```

Deploy Rome from the repository root with `nix run .# -- rome`.
