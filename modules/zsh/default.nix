{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.my.zsh;
in
{
  options.my.zsh = {
    enable = mkEnableOption "Enable zsh and install default programs";
  };

  config = mkIf cfg.enable {
    users.defaultUserShell = pkgs.zsh;

    environment = {
      shellInit = ''
        export ZDOTDIR=$HOME/.config/zsh
      '';

      systemPackages = with pkgs; [
        coreutils-full
        ripgrep
        ripgrep-all
        tldr
        fd
        fzf
        bat
        eza
        file
        procs
        jq
        dogdns
        yq
        manix
        git
        pv
        sd
        du-dust
        ouch
        zsh
        curl
        wget
        bash-completion
        usbutils

        man-db
        man-pages
        man-pages-posix
        stdmanpages
      ];

      shellAliases = {
        ls = "eza --group-directories-first";
        l = "eza -1";
        ll = "eza -lg";
        la = "eza -la";

        ps = "procs";

        opt = ''
          manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | fzf --preview="manix {}" | xargs manix
        '';
      };
    };

    programs.zsh = {
      enable = true;

      # histSize = 10000;
      enableCompletion = true;
      autosuggestions.enable = true;

      shellInit = ''
        bindkey -v
        setopt globdots
      '';
    };

    # Needed for zsh completion of system packages, e.g. systemd
    environment.pathsToLink = [ "/share/zsh" ];
  };
}
