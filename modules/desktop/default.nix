{ config, lib, pkgs, ... }:

{
  imports = [
    ./bspwm.nix
    ./browsers
    ./apps
    ./term
  ];
}
