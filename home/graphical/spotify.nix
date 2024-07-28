{
  unstable-pkgs,
  config,
  ...
}: {
  home.packages = with unstable-pkgs; [
    spotify-player
  ];
}
