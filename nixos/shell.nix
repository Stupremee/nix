{ ... }: {
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
}
