{
  pkgs,
  unstable-pkgs,
  config,
  lib,
  ...
}: let
  inherit (pkgs) fetchFromGitHub;

  procWatch = pkgs.writeShellScriptBin "proc-watch" ''
    cmd="$1"
    shift

    $cmd $@ &
    pid="$!"

    trap_ctrlc() {
      kill -SIGINT $pid || true
      wait $pid || true

      exit
    }

    trap trap_ctrlc SIGHUP SIGINT SIGTERM

    while read; do
      kill -SIGINT $pid || true
      wait $pid || true

      $cmd $@ &
      pid="$!"
    done
  '';

  zshPlugin = src: rec {
    inherit src;
    name = src.pname;
    file = "share/${name}/${name}.zsh";
  };

  ohmyzsh = fetchFromGitHub {
    owner = "ohmyzsh";
    repo = "ohmyzsh";
    rev = "ac0924930d48217e127523809dc5d386fb3403a4";
    sha256 = "sha256-j7ppGmNnfgep6JDdv5nn2gUGSOx4iPPc5afL1WDF3ZY=";
  };
in {
  home.packages = with pkgs; [procWatch];

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;

    package = unstable-pkgs.atuin;

    settings = {
      auto_sync = false;
    };
  };

  programs.zsh = {
    enable = true;

    enableCompletion = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;

    autocd = true;
    defaultKeymap = "viins";
    dotDir = ".config/zsh";

    history = {
      path = "${config.xdg.dataHome}/zsh/zshHistory";
      extended = true;
    };

    plugins = with pkgs; [
      (zshPlugin zsh-syntax-highlighting)
      (zshPlugin zsh-history-substring-search)
    ];

    envExtra = ''
      export ZSH_CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
      mkdir -p $ZSH_CACHE_DIR/completions

      function load_plugin() {
        source "${ohmyzsh}/plugins/$1/$1.plugin.zsh"
      }
    '';

    initExtra = let
      tty = lib.optionalString pkgs.stdenv.isLinux " && [[ \"$(tty)\" != /dev/tty* ]]";
    in ''
      if command -v tmux &> /dev/null && [ "$TMUX" = "" ]${tty}; then
        tmux
      fi

      ${pkgs.any-nix-shell}/bin/any-nix-shell zsh --info-right | source /dev/stdin

      # Include hidden files in completions
      _comp_options+=(globdots)
    '';
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;

    nix-direnv.enable = true;
  };

  programs.nix-index-database = {
    comma.enable = true;
  };

  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
    symlinkToCacheHome = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;

      character = {
        success_symbol = "[λ ›](bold green)";
        error_symbol = "[λ ›](bold red)";
        vicmd_symbol = "[λ ·](bold green)";
      };

      cmd_duration = {
        show_notifications = false;
        min_time = 10000;
        min_time_to_notify = 60000;
      };
    };
  };
}
