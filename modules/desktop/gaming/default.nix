{ config, lib, pkgs, ... }:

{
  imports = [
    ./emulators.nix
    ./steam.nix
    ./multimc.nix
    ./lutris.nix
  ];
}
