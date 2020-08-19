{ config, lib, pkgs, ... }:

{
  imports = [
    ./discord.nix
    ./rofi.nix
    ./qemu.nix
  ];
}
