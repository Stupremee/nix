{ config, lib, pkgs, ... }:

{
  imports = [
    ./bspwm.nix
    ./browsers
    ./apps
    ./gaming
    ./term
  ];
}
