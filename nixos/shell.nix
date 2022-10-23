{ pkgs, unstable-pkgs, ... }: {
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;

    histSize = 10000;
    enableCompletion = true;

    autosuggestions.enable = true;
    autosuggestions.async = true;

    syntaxHighlighting.enable = true;

    shellInit = ''
      bindkey -v
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
      manix
      git
      unstable-pkgs.neovim

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

      cat = "bat";
      sc = "systemctl";
      ps = "procs";
      g = "git";

      opt = ''
        manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | fzf --preview="manix {}" | xargs manix
      '';
    };
  };
}
