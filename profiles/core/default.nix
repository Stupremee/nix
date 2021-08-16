# The core module is used for every host machine
# and contains common configuration for fonts,
# zsh, and some more stuff.

{ pkgs, ... }: {
  # Configure global settings related the NixOs and Nix.
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    allowedUsers = [ "@wheel" ];
    trustedUsers = [ "root" "@wheel" ];

    useSandbox = true;

    autoOptimiseStore = true;
    optimise = {
      automatic = true;
      dates = [ "11:00" ];
    };

    gc = {
      automatic = true;
      # Run garbage collector every sunday at 1PM
      dates = "Sun 13:00";
      options = "--delete-older-than 30d";
    };
  };

  # Set timezone and locale
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Berlin";

  # Install all fonts and set the default fonts
  fonts = {
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "Noto" ]; })
      noto-fonts
      noto-fonts-emoji
      fira-code
    ];

    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" "Noto Serif Nerd Font" ];
      sansSerif = [ "NotoSans Nerd Font" "Noto Sans" ];
      monospace = [ "Fira Code Nerd Font" "Fira Code Font" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # Configure zsh shell.
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
  };

  # Shell aliases and core packages
  environment = {
    systemPackages = with pkgs; [
      coreutils-full
      ripgrep
      ripgrep-all
      tldr
      fd
      fzf
      bat
      exa
      file
      pulsemixer
      procs
      tokei
      # Currently broken idk
      # licensor
      jq
      manix
      git
      git-crypt

      man-db
      man-pages
      posix_man_pages
      stdmanpages

      agenix
    ];

    shellAliases = {
      mixer = "pulsemixer";

      ls = "exa --group-directories-first";
      l = "exa -1";
      ll = "exa -lg";
      la = "exa -la";

      sc = "systemctl";
      ps = "procs";
      g = "git";

      nsh = "nix-shell";

      opt = ''
        manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | fzf --preview="manix {}" | xargs manix
      '';
    };
  };

  services.earlyoom.enable = true;
  security = {
    protectKernelImage = true;
  };
}
