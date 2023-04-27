{
  pkgs,
  inputs,
  system,
  ...
}: {
  imports = [./k8s.nix];

  home.packages = with pkgs; [
    dbeaver
    inputs.devenv.packages."${system}".devenv
    ghidra-bin
    remmina
    httpie
    sccache
  ];

  home.sessionVariables = {
    SCCACHE_DIR = "/mnt/hdd/.sccache/";
  };
}
