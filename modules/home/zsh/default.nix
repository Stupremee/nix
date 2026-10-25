{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.my.zsh;

  zshPlugin = src: rec {
    inherit src;
    name = src.pname;
    file = "share/${name}/${name}.zsh";
  };
in
{
  options.my.zsh = {
    enable = mkEnableOption "Enable ZSH shell";

    # Rex sets REX_SESSION locally too, so only hosts reached through Rex should mark it.
    rexPrompt = mkEnableOption "showing user and host in Rex sessions, like Starship does over SSH";
  };

  config = mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      enableZshIntegration = true;

      settings = {
        auto_sync = false;
      };
    };

    programs.zsh = {
      enable = true;

      enableCompletion = true;
      autosuggestion.enable = true;

      syntaxHighlighting = {
        enable = true;
      };

      autocd = true;
      defaultKeymap = "viins";
      dotDir = "${config.home.homeDirectory}/.config/zsh";

      history = {
        path = "${config.xdg.dataHome}/zsh/zshHistory";
        extended = true;
      };

      plugins = with pkgs; [
        (zshPlugin zsh-history-substring-search)
      ];

      envExtra = ''
        export ZSH_CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
        mkdir -p $ZSH_CACHE_DIR/completions
      '';

      initContent = ''
        ${pkgs.any-nix-shell}/bin/any-nix-shell zsh --info-right | source /dev/stdin

        # Newer Vite+ installs follow XDG; older ones (Rome, the Mac) live in ~/.vite-plus.
        for vp_env in "''${XDG_CONFIG_HOME:-$HOME/.config}/vite-plus/env" "$HOME/.vite-plus/env"; do
          if [ -f "$vp_env" ]; then
            source "$vp_env"
            break
          fi
        done
        unset vp_env

        if (( $+commands[mise] )); then
          eval "$(mise activate zsh)"
        fi

        if (( $+commands[forge] )); then
          eval "$(forge zsh theme)"
          eval "$(forge zsh plugin)"
        fi

        if (( $+commands[wt] )); then
          eval "$(wt config shell init zsh)"
        fi

        # Include hidden files in completions
        _comp_options+=(globdots)
      '';
    };

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;

      nix-direnv.enable = true;
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = mkMerge [
        {
          add_newline = true;

          character =
            let
              vicmd = "[λ ·](bold green)";
            in
            {
              success_symbol = "[λ ›](bold green)";
              error_symbol = "[λ ›](bold red)";
              vimcmd_symbol = vicmd;
              vimcmd_replace_one_symbol = vicmd;
              vimcmd_replace_symbol = vicmd;
              vimcmd_visual_symbol = vicmd;
            };

          cmd_duration = {
            show_notifications = false;
            min_time = 10000;
            min_time_to_notify = 60000;
          };
        }

        # The SSH look with 🦖 in place of 🌐. hostname ANDs ssh_only with
        # detect_env_vars, so SSH has to be listed there as well.
        (mkIf cfg.rexPrompt {
          format = "$username\${env_var.REX_SESSION}$hostname$all";
          username.detect_env_vars = [ "REX_SESSION" ];
          hostname = {
            ssh_only = false;
            detect_env_vars = [
              "SSH_CONNECTION"
              "REX_SESSION"
            ];
          };
          env_var.REX_SESSION.format = "[🦖 ](bold dimmed green)";
        })
      ];
    };

    programs.nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.nix-index-database.comma.enable = true;
  };
}
