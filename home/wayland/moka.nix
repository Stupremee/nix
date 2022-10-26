{ pkgs, theme, ... }: {
  home.packages = [ pkgs.libnotify ];

  programs.mako = {
    enable = true;

    borderRadius = 4;
    borderSize = 2;

    backgroundColor = theme.base;
    textColor = theme.text;
    borderColor = theme.blue;
    progressColor = theme.surface0;

    extraConfig = ''
      [urgency=low]
      border-color=${theme.lavender}

      [urgency=normal]
      border-color=${theme.blue}

      [urgency=critical]
      border-color=${theme.red}
    '';
  };
}
