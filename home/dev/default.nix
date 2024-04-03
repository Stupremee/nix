{
  pkgs,
  unstable-pkgs,
  packages,
  ...
}: {
  imports = [./k8s.nix];

  home.packages = with pkgs; [
    dbeaver
    unstable-pkgs.devenv
    httpie
    websocat
    numbat
    burpsuite

    packages.tproxy
  ];

  home.sessionVariables = {
    SCCACHE_DIR = "/mnt/hdd/.sccache/";
  };
}
