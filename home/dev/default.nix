{
  pkgs,
  packages,
  inputs,
  system,
  ...
}: {
  imports = [./k8s.nix];

  home.packages = with pkgs; [
    dbeaver
    inputs.devenv.packages."${system}".devenv
    httpie

    packages.tproxy
  ];

  home.sessionVariables = {
    SCCACHE_DIR = "/mnt/hdd/.sccache/";
  };
}
