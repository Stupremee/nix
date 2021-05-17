# Profile for supporting ZSA keyboards, like my Moonlander
{ pkgs, ... }:
{
  hardware.keyboard.zsa.enable = true;
  environment.systemPackages = with pkgs; [ wally-cli ];
}
