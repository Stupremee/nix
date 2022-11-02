{
  pkgs,
  theme,
  ...
}: {
  home.packages = [pkgs.swaylock-effects];

  xdg.configFile."swaylock/config".text = ''
    clock
    effect-blur=10x3
    font=monospace
    ignore-empty-password
    screenshots

    indicator
    indicator-radius=130

    line-uses-ring

    bs-hl-color=${theme.mauve}
    key-hl-color=${theme.blue}

    inside-color=${theme.yellow}
    ring-color=${theme.peach}
    separator-color=${theme.peach}

    inside-clear-color=${theme.pink}
    ring-clear-color=${theme.mauve}
    text-clear-color=${theme.overlay1}

    inside-ver-color=${theme.sky}
    ring-ver-color=${theme.teal}
    text-ver-color=${theme.overlay1}

    inside-wrong-color=${theme.maroon}
    ring-wrong-color=${theme.red}
    text-wrong-color=${theme.text}
  '';
}
