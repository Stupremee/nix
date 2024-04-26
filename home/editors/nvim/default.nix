{
  unstable-pkgs,
  packages,
  inputs,
  system,
  ...
}: let
  pkg = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
    pkgs = unstable-pkgs;
    module = import ./config;
    extraSpecialArgs = {
      inherit packages;
    };
  };
in {
  home.packages = [pkg];

  home.sessionVariables = {
    MANPAGER = "/nvim +Man!";
    EDITOR = "nvim";
  };
}
