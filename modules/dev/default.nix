{ pkgs, ... }:
{
  imports = [
    ./cc.nix
    ./lua.nix
    ./node.nix
    ./python.nix
    ./rust.nix
    ./java.nix
  ];

  options = {};
  config = {};
}
