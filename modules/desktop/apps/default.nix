{ config, lib, pkgs, ... }:

{
  imports = [
    ./discord.nix
    ./rofi.nix
    ./qemu.nix
    ./radare2.nix
  ];
}
