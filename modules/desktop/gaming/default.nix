{ config, lib, pkgs, ... }:

{
  imports = [
    ./emulators.nix
    ./steam.nix
  ];
}
