{
  config,
  unstable-pkgs,
  theme,
  ...
}: {
  home.sessionVariables.TERMINAL = "${config.programs.rio.package}/bin/rio";
  programs.rio = {
    enable = true;
    package = unstable-pkgs.rio;
    settings = {
      navigation.mode = "Plain";

      fonts = {
        family = "MonaspiceNe Nerd Font Mono";
        size = 14;
      };

      bindings.keys = [
        {
          key = "v";
          "with" = "alt";
          action = "Paste";
        }
        {
          key = "c";
          "with" = "alt";
          action = "Copy";
        }
      ];

      colors = {
        foreground = theme.text;
        background = theme.base;
        black = theme.subtext1;
        blue = theme.blue;
        cursor = theme.rosewater;
        cyan = theme.teal;
        green = theme.green;
        magenta = theme.pink;
        red = theme.red;
        white = theme.surface2;
        yellow = theme.yellow;

        tabs = "#1E1E2E";
        tabs-active = "#B4BEFE";
        selection-foreground = theme.base;
        selection-background = theme.rosewater;

        dim-black = theme.subtext1;
        dim-blue = theme.blue;
        dim-cyan = theme.teal;
        dim-foreground = theme.text;
        dim-green = theme.green;
        dim-magenta = theme.pink;
        dim-red = theme.red;
        dim-white = theme.surface2;
        dim-yellow = theme.yellow;

        light-black = theme.subtext0;
        light-blue = theme.blue;
        light-cyan = theme.teal;
        light-foreground = theme.text;
        light-green = theme.green;
        light-magenta = theme.pink;
        light-red = theme.red;
        light-white = theme.surface1;
        light-yellow = theme.yellow;
      };
    };
  };
}
