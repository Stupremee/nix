{ pkgs, ... }: {
  gtk = {
    enable = true;

    theme.name = "Nordic";
    theme.package = pkgs.nordic;

    iconTheme.name = "Papirus";
    iconTheme.package = pkgs.papirus-icon-theme;
  };
}
