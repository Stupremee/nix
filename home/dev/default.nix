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
  ];
}
