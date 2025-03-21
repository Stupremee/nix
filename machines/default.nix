{ inputs, self, ... }:
{
  flake =
    let
      inherit (inputs) nixpkgs;
      inherit (builtins)
        listToAttrs
        attrNames
        attrValues
        readDir
        ;
      inherit (nixpkgs.lib) filterAttrs;
    in
    {
      nixosConfigurations = listToAttrs (
        map (x: {
          name = x;
          value = self.nixos-unified.lib.mkLinuxSystem { home-manager = true; } {
            imports =
              (attrValues self.nixosModules)
              ++ (with inputs; [
                disko.nixosModules.default
                impermanence.nixosModules.default
                agenix.nixosModules.default
                agenix-rekey.nixosModules.default

                ./${x}/default.nix
              ]);
          };
        }) (attrNames (filterAttrs (_: ty: ty == "directory") (readDir ./.)))
      );
    };
}
