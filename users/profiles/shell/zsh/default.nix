{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.modules.zsh;

  zshUsersPlugin = src: rec {
    inherit src;
    name = src.pname;
    file = "share/${name}/${name}.zsh";
  };
in
{
  options.modules.zsh = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultOptions = [
        "--color=fg:#e5e9f0,bg:#3b4251,hl:#81a1c1"
        "--color=fg+:#e5e9f0,bg+:#3b4251,hl+:#81a1c1"
        "--color=info:#eacb8a,prompt:#bf6069,pointer:#b48dac"
        "--color=marker:#a3be8b,spinner:#b48dac,header:#a3be8b"
      ];
    };

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      autocd = true;
      defaultKeymap = "viins";
      dotDir = ".config/zsh";

      plugins = with pkgs; [
        (zshUsersPlugin zsh-syntax-highlighting)
        (zshUsersPlugin zsh-history-substring-search)
        {
          name = "first-tab";
          src = lib.cleanSource ./.;
          file = "first-tab.zsh";
        }
        {
          name = "fzf-completions";
          src = fzf;
          file = "share/fzf/completion.zsh";
        }
        {
          name = "fzf-key-bindings";
          src = fzf;
          file = "share/fzf/key-bindings.zsh";
        }
      ];

      initExtra = ''
        ${pkgs.any-nix-shell}/bin/any-nix-shell zsh --info-right | source /dev/stdin

        bindkey -v

        autoload -U colors && colors
        setopt incappendhistory
        setopt sharehistory 

        autoload -U compinit
        zstyle ':completion:*' menu select
        zmodload zsh/complist
        compinit

        # Include hidden files in completions
        _comp_options+=(globdots)

        # Use vi keys in completion menu
        bindkey -M menuselect 'h' vi-backward-char
        bindkey -M menuselect 'k' vi-up-line-or-history
        bindkey -M menuselect 'l' vi-forward-char
        bindkey -M menuselect 'j' vi-down-line-or-history

        bindkey -M vicmd 'k' history-substring-search-up
        bindkey -M vicmd 'j' history-substring-search-down

        bindkey '^I' first-tab

        setopt extendedglob

        if command -v tmux &> /dev/null
        then
          if [ "$TMUX" = "" ]; then tmux; fi
        fi
      '';
    };

    home.sessionVariables = with pkgs; {
      FZF_DEFAULT_COMMAND = "${fd}/bin/fd --type f";
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = builtins.fromTOML (builtins.readFile ./starship.toml);
    };

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      enableNixDirenvIntegration = true;
    };

    services.lorri.enable = true;
  };
}
