{ config, lib, pkgs, ... }:

{
  imports = [
    ./docker.nix
    ./lorri.nix
  ];
}
