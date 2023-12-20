{
  unstable-pkgs,
  theme,
  ...
}: {
  programs.helix = {
    enable = true;
    package = unstable-pkgs.helix;

    extraPackages = with unstable-pkgs; [
      rust-analyzer
    ];

    settings = {
      theme = "catppuccin_${theme.name}";
    };
  };
}
