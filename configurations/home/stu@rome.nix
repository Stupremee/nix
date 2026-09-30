{
  config,
  lib,
  pkgs,
  ...
}:
let
  userBinDirectories = [
    ".vite-plus/bin"
    ".local/bin"
    "bin"
    ".cargo/bin"
    "go/bin"
    ".bun/bin"
    ".local/share/pnpm"
  ];

  tscWatchdogLimitMiB = 4096;
in
{
  catppuccin.flavor = "latte";

  assertions = [
    {
      assertion = !lib.any (package: lib.hasPrefix "nodejs" (lib.getName package)) config.home.packages;
      message = "Node.js on Rome must be managed by Vite+, not Home Manager.";
    }
  ];

  home = {
    packages = [ pkgs.python3 ];

    sessionPath = map (directory: "$HOME/${directory}") userBinDirectories;
  };

  systemd.user.sessionVariables.PATH = lib.concatStringsSep ":" (
    map (directory: "${config.home.homeDirectory}/${directory}") userBinDirectories ++ [ "\${PATH}" ]
  );

  # t3code writes its own unit file, so limit it via a drop-in. Agent processes share this
  # cgroup, so the cap keeps a runaway from starving ssh and system services. It does not
  # kill slow growers quickly (the cgroup thrashes at the cap), which is what
  # tsc-watchdog below is for.
  xdg.configFile."systemd/user/t3code.service.d/limits.conf".text = ''
    [Service]
    MemoryMax=10G
    MemorySwapMax=2G
  '';

  # Kills tsc/tsgolint processes spawned by agents once they exceed tscWatchdogLimitMiB of
  # RSS, logging what was killed. Inspect with `journalctl --user -u tsc-watchdog`.
  systemd.user.services.tsc-watchdog = {
    Unit.Description = "Kill runaway tsc and tsgolint processes";
    Install.WantedBy = [ "default.target" ];
    Service = {
      Restart = "always";
      ExecStart = lib.getExe (
        pkgs.writeShellApplication {
          name = "tsc-watchdog";
          runtimeInputs = [
            pkgs.coreutils
            pkgs.procps
          ];
          text = ''
            limit_kib=$((${toString tscWatchdogLimitMiB} * 1024))

            while true; do
              ps -u "$(id -u)" -o pid=,rss=,comm= | while read -r pid rss comm; do
                case "$comm" in tsc | tsgolint) ;; *) continue ;; esac
                ((rss > limit_kib)) || continue

                cwd=$(readlink "/proc/$pid/cwd" || true)
                args=$(ps -o args= -p "$pid" || true)
                if kill -KILL "$pid" 2>/dev/null; then
                  echo "killed $comm pid=$pid rss=$((rss / 1024))MiB cwd=$cwd args=$args"
                fi
              done
              sleep 2
            done
          '';
        }
      );
    };
  };

  programs.zsh.initContent = lib.mkAfter ''
    if [ -r "$HOME/.zshrc" ]; then
      source "$HOME/.zshrc"
    fi
  '';

  programs.git.signing = {
    key = lib.mkForce null;
    signByDefault = lib.mkForce false;
  };

  my = {
    dev.enable = true;
    tmux.enable = lib.mkForce false;
  };
}
