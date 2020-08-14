{ config, options, pkgs, lib, ... }:
with lib;
let
  cfg = config.modules.shell;
in {
  options.modules.shell.zsh = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.zsh.enable {
    my = {
      packages = with pkgs; [
        zsh
        nix-zsh-completions
        zsh-completions
        zsh-syntax-highlighting
        zsh-fast-syntax-highlighting
        starship
        file
        bat
        exa
        fd
        fzf
        ytop
        tldr
        tree
        ripgrep
        ripgrep-all
        pulsemixer
        procs
        pastel
      ];
      env.ZDOTDIR   = "$XDG_CONFIG_HOME/zsh";
      env.ZSH_CACHE = "$XDG_CACHE_HOME/zsh";
      zsh.rc = ''
        source "${pkgs.fzf}/share/fzf/completion.zsh"
        source "${pkgs.fzf}/share/fzf/key-bindings.zsh"
        source "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
      '';

      alias.exa = "exa --group-directories-first";
      alias.l   = "exa -1";
      alias.ll  = "exa -lg";
      alias.la  = "exa -la";
      alias.sc = "systemctl";
      alias.ssc = "sudo systemctl";
      alias.ps = "procs";

      home.xdg.configFile."zsh" = {
        source = <config/zsh>;
        recursive = true;
      };
    };

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableGlobalCompInit = true;
      promptInit = "";
    };

    system.userActivationScripts.cleanupZgen = "rm -fv $XDG_CACHE_HOME/zsh/*";
  };
}
