{
  unstable-pkgs,
  theme,
  ...
}: {
  programs.helix = let
    inherit (builtins) fromTOML readFile;
  in {
    enable = true;
    package = unstable-pkgs.helix;

    extraPackages = with unstable-pkgs; [
      rust-analyzer
    ];

    settings = {
      theme = theme.name;
    };

    themes."${theme.name}" = fromTOML (readFile ./themes/${theme.name}.toml);
  };
}
