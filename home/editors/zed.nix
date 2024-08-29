{unstable-pkgs, ...}: {
  home.packages = with unstable-pkgs; [
    zed-editor
  ];
}
