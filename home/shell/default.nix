{ pkgs, ... }:
let
  zshUsersPlugin = src: rec {
    inherit src;
    name = src.pname;
    file = "share/${name}/${name}.zsh";
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
    enableCompletion = true;
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

    shellAliases = {
      mixer = "pulsemixer";
      exa = "exa --group-directories-first";
      l = "exa -1";
      ll = "exa -lg";
      la = "exa -la";
      sc = "systemctl";
      ps = "procs";
      nsh = "nix-shell --run zsh";
      g = "git";
    };

    initExtra = ''
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
  xdg.configFile."direnv/lib/use_flake.sh".text = ''
    use_flake() {
      watch_file flake.nix
      watch_file flake.lock
      eval "$(nix print-dev-env --profile "$(direnv_layout_dir)/flake-profile")"
    }
  '';

  services.lorri.enable = true;

  home.packages = with pkgs; [
    coreutils-full
    ripgrep
    ripgrep-all
    tldr
    fd
    fzf
    gotop
    exa
    bat
    file
    pulsemixer
    procs
    licensor
    tokei
  ];
}
