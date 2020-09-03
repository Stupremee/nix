{ config, options, pkgs, lib, ... }:

{
  imports = [
    ./zsh.nix
    ./git.nix
    ./mc.nix
    ./pulsemixer.nix
    ./gnupg.nix
    ./ranger.nix
    ./pass.nix
    ./bitwarden.nix
    ./yubico.nix
  ];
}
