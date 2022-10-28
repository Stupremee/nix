{ pkgs, theme, config, ... }:
let
  zshPlugin = src: rec {
    inherit src;
    name = src.pname;
    file = "share/${name}/${name}.zsh";
  };
in
{
  home.packages = with pkgs; [ comma ];

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
