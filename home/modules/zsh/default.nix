{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.my.zsh;

  zshPlugin = src: rec {
    inherit src;
    name = src.pname;
    file = "share/${name}/${name}.zsh";
  };
in {
  options.my.zsh.enable =
    mkEnableOption "Enable ZSH shell";

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
      dotDir = ".config/zsh";

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

      initExtra = ''
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

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = true;

        character = let
          vicmd = "[λ ·](bold green)";
        in {
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
      };
    };
  };
}
