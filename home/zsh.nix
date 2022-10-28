{ pkgs, theme, ... }:
let
  zshPlugin = src: rec {
    inherit src;
    name = src.pname;
    file = "share/${name}/${name}.zsh";
  };
in
{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    defaultOptions = with theme; [
      "--color=bg+:${surface0},bg:${base},spinner:${rosewater},hl:${red}"
      "--color=fg:${text},header:${red},info:${mauve},pointer:${rosewater}"
      "--color=marker:${rosewater},fg+:${text},prompt:${mauve},hl+:${red}"
    ];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    autocd = true;
    defaultKeymap = "viins";
    dotDir = ".config/zsh";

    history = {
      extended = true;
    };

    plugins = with pkgs; [
      (zshPlugin zsh-syntax-highlighting)
      (zshPlugin zsh-history-substring-search)
    ];

    initExtra = ''
      # Include hidden files in completions
      _comp_options+=(globdots)
    '';
  };

  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
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
        show_notifications = true;
        min_time = 10000;
        min_time_to_notify = 60000;
      };
    };
  };
}
