{ inputs, self, ... }:
{
  flake =
    let
      inherit (inputs) nixpkgs;
      inherit (builtins) listToAttrs attrNames readDir;
      inherit (nixpkgs.lib) filterAttrs;
    in
    {
      nixosModules =
        listToAttrs (
          map (x: {
            name = x;
            value =
              {
                config,
                pkgs,
                lib,
                modulesPath,
                ...
              }:
              {
                imports = [
                  (import ./${x} {
                    flake-self = self;
                    inherit
                      pkgs
                      lib
                      config
                      modulesPath
                      inputs
                      nixpkgs
                      ;
                  })
                ];
              };
          }) (attrNames (filterAttrs (_: ty: ty == "directory") (readDir ./.)))
        )
        // {
          home =
            {
              config,
              pkgs,
              lib,
              modulesPath,
              ...
            }:
            import ../home {
              flake-self = self;
              inherit
                pkgs
                lib
                config
                modulesPath
                inputs
                nixpkgs
                ;
            };
        };
    };
}
