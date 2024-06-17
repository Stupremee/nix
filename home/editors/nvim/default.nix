{
  unstable-pkgs,
  packages,
  inputs,
  system,
  theme,
  ...
}: let
  pkg = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
    pkgs = unstable-pkgs;
    module = import ./config;
    extraSpecialArgs = {
      inherit packages theme;
    };
  };
in {
  home.packages = [pkg];

  home.sessionVariables = {
    MANPAGER = "nvim +Man!";
    EDITOR = "nvim";
  };
}
