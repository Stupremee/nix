{ pkgs, ... }: {
  gtk = {
    enable = true;

    theme.name = "Nordic";
    theme.package = pkgs.nordic;

    iconTheme.name = "Paper";
    iconTheme.package = pkgs.paper-icon-theme;
  };
}
