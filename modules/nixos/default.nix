{ flake, lib, ... }:
with lib;
{
  # Import modules from all inputs,
  # and all nixosModules, as they need to be
  # enabled separately
  imports =
    with flake.inputs;
    [
      disko.nixosModules.default
      impermanence.nixosModules.default
      agenix.nixosModules.default
      agenix-rekey.nixosModules.default
      cliproxyapi.nixosModules.default
      postbote.nixosModules.default
      lanzaboote.nixosModules.lanzaboote
    ]
    ++ (attrValues (filterAttrs (name: _: name != "default") flake.inputs.self.nixosModules));
}
