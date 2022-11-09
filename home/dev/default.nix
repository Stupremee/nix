{pkgs, ...}: {
  imports = [./k8s.nix];

  home.packages = with pkgs; [
    dbeaver
  ];
}
