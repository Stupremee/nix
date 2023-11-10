{pkgs, ...}: {
  programs.zsh = {
    enable = true;

    # histSize = 10000;
    enableCompletion = true;

    shellInit = ''
      bindkey -v
      setopt globdots
    '';
  };

  # core packages for shell usage
  environment = {
    systemPackages = with pkgs; [
      coreutils-full
      ripgrep
      ripgrep-all
      tldr
      fd
      fzf
      bat
      exa
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

      man-db
      man-pages
      posix_man_pages
      stdmanpages
    ];

    shellAliases = {
      ls = "exa --group-directories-first";
      l = "exa -1";
      ll = "exa -lg";
      la = "exa -la";

      sc = "systemctl";
      ps = "procs";
      g = "git";

      opt = ''
        manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | fzf --preview="manix {}" | xargs manix
      '';
    };
  };
}
