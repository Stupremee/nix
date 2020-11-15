{ pkgs, ... }:
let
  simpleZshPlugin = src: {
    inherit src;
    name = src.pname;
  };
in {
  imports = [ ./terminal.nix ];

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
    enableAutosuggestions = true;
    enableCompletion = true;
    autocd = true;
    defaultKeymap = "viins";
    dotDir = ".config/zsh";
    plugins = with pkgs; [
      simpleZshPlugin
      zsh-completions
      simpleZshPlugin
      nix-zsh-completions
      simpleZshPlugin
      zsh-syntax-highlighting
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

    shellAliases = {
      mixer = "pulsemixer";
      exa = "exa --group-directories-first";
      l = "exa -1";
      ll = "exa -lg";
      la = "exa -la";
      sc = "systemctl";
      ps = "procs";
      nsh = "nix-shell --run zsh";
    };

    initExtra = ''
      ZSH_AUTOSUGGEST_USE_ASYNC=1
      ZSH_AUTOSUGGEST_STRATEGY=(history completion)

      # Use vi keys in completion menu
      bindkey -M menuselect 'h' vi-backward-char
      bindkey -M menuselect 'k' vi-up-line-or-history
      bindkey -M menuselect 'l' vi-forward-char
      bindkey -M menuselect 'j' vi-down-line-or-history

      bindkey -M vicmd 'k' history-substring-search-up
      bindkey -M vicmd 'j' history-substring-search-down

      bindkey '^I' first-tab

      setopt extendedglob
    '';
  };

  home.sessionVariables = with pkgs; {
    FZF_DEFAULT_COMMAND = "${ripgrep}/bin/rg --files --hidden";
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromTOML ./starship.toml;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableNixDirenvIntegration = true;
  };

  home.packages = with pkgs; [
    coreutils-full
    ripgrep
    ripgrep-all
    tldr
    fd
    fzf
    ytop
    exa
    bat
    file
    pulsemixer
    procs
    licensor
    tokei
  ];
}
