{inputs, ...}: {
  perSystem = {
    pkgs,
    system,
    inputs',
    ...
  }: let
    mapPackages = f:
      with builtins;
        listToAttrs (map
          (name: {
            inherit name;
            value = f name;
          })
          (filter (v: v != null) (attrValues (mapAttrs
            (k: v:
              if v == "directory" && k != "_sources" && k != "nodePackages"
              then k
              else null)
            (readDir ./.)))));

    nodePackages = import ./nodePackages {inherit pkgs;};
  in {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [inputs.rust-overlay.overlays.default];
    };

    packages =
      (mapPackages (
        name: let
          sources = (import ./_sources/generated.nix) {inherit (pkgs) fetchurl fetchgit fetchFromGitHub;};
          package = import ./${name};

          args = builtins.intersectAttrs (builtins.functionArgs package) {
            inherit sources;
            source = sources."${name}";
          };
        in
          pkgs.callPackage package args
      ))
      // nodePackages;
  };
}
