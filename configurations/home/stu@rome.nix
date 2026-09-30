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

  tscWatchdogLimitMiB = 8192;
  tscWatchdogMinAgeSec = 120;
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

  # Kills tsc/tsgolint processes spawned by agents that have run for tscWatchdogMinAgeSec and
  # use more than tscWatchdogLimitMiB of RAM + swap, logging what was killed. Swap counts
  # because at the t3code cap the kernel swaps the process out, so RSS alone can stay under
  # the limit while it thrashes. Inspect with `journalctl --user -u tsc-watchdog`.
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
            pkgs.gawk
            pkgs.procps
          ];
          text = ''
            limit_kib=$((${toString tscWatchdogLimitMiB} * 1024))
            min_age_s=${toString tscWatchdogMinAgeSec}

            while true; do
              ps -u "$(id -u)" -o pid=,etimes=,rss=,comm= | while read -r pid age_s rss comm; do
                case "$comm" in tsc | tsgolint) ;; *) continue ;; esac
                ((age_s >= min_age_s)) || continue

                swap=$(awk '/^VmSwap:/ { print $2 }' "/proc/$pid/status" 2>/dev/null || true)
                mem_kib=$((rss + ''${swap:-0}))
                ((mem_kib > limit_kib)) || continue

                cwd=$(readlink "/proc/$pid/cwd" || true)
                args=$(ps -o args= -p "$pid" || true)
                if kill -KILL "$pid" 2>/dev/null; then
                  echo "killed $comm pid=$pid mem=$((mem_kib / 1024))MiB age=''${age_s}s cwd=$cwd args=$args"
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
