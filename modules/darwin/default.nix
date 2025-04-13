{ flake, lib, ... }:
with lib;
{
  imports =
    with flake.inputs;
    [
      ../nixos/nix-common
    ]
    ++ (attrValues (filterAttrs (name: _: name != "default") flake.inputs.self.darwinModules));
}
