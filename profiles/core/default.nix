# The core module is used for every host machine
# and contains common configuration for fonts,
# zsh, and some more stuff.

{ pkgs, ... }: {
  # Configure global settings related the NixOs and Nix.
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    allowedUsers = [ "@wheel" ];
    trustedUsers = [ "root" "@wheel" ];

    useSandbox = true;

    autoOptimiseStore = true;
    optimise = {
      automatic = true;
      dates = "11:00";
    };

    gc = {
      automatic = true;
      dates = "11:00";
      options = "--delete-ollder-than 30d";
    };
  };

  # Set timezone and locale
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Berlin";

  # Install all fonts and set the default fonts
  fonts = {
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "Noto" ]; })
      noto-fonts-emoji
    ];

    fontconfig.defaultFonts = {
      serif = [ "Noto Serif Nerd Font" ];
      sansSerif = [ "Noto Sans Nerd Font" ];
      monospace = [ "FiraCode Nerd Font" ];
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

    histFile = "$HOME/.config/zsh/zsh_history";
    histSize = 10000;

    promptInit = ''
      eval "$(${pkgs.starship}/bin/starship init zsh)"
    '';

    shellInit = ''
      export STARSHIP_CONFIG=${
        pkgs.writeText "starship.toml" (fileContents ./starship.toml)
      }
    '';

    interactiveShellInit = ''
      eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
    '';
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
      licensor
      jq
      manix
      git
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

      opt = ''
        manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | fzf --preview="manix '{}'" | xargs manix
      '';
    };
  };

  services.earlyoom.enable = true;
  security = {
    hideProcessInformation = true;
    protectKernelImage = true;
  };
}
