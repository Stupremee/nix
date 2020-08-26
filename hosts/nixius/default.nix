{ pkgs, options, config, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common.nix
  ];

  modules = {
    shell = {
      zsh.enable = true;
      ranger.enable = true;
      git.enable = true;
      pulsemixer.enable = true;
      pass.enable = true;
      bitwarden.enable = true;

      gnupg.enable = true;
      yubico.enable = true;
    };

    desktop = {
      bspwm.enable = true;

      browsers.default = "firefox";
      browsers.firefox.enable = true;
      browsers.qutebrowser.enable = true;

      term.alacritty.enable = true;
      term.default = "alacritty";

      apps.discord.enable = true;
      apps.rofi.enable = true;
      apps.qemu.enable = true;
      apps.r2.enable = true;

      gaming.steam.enable = true;
    };

    editors = {
      default = "vim";
      vim.enable = true;
      emacs.enable = true;
    };

    dev = {
      rust.enable = true;
      cc.enable = true;
      python.enable = true;
    };

    media = {
      mpv.enable = true;
      spotify.enable = true;
    };

    services = {
      docker.enable = true;
      lorri.enable = true;
    };

    themes.nord.enable = true;
  };

  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Berlin";
}

