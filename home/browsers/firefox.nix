{ pkgs }: {
  programs.firefox = {
    enable = true;
    package = pgks.firefox-devedition-bin;
  };
}
