{ self, config, lib, pkgs, ... }:
let inherit (lib) fileContents;
in
{
  imports = [ ../cachix ];

  nix.systemFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];

  # Store SSH keys on persistent storage
  environment.persist.files = [
    "/etc/ssh/ssh_host_rsa_key"
    "/etc/ssh/ssh_host_rsa_key.pub"
    "/etc/ssh/ssh_host_ed25519_key"
    "/etc/ssh/ssh_host_ed25519_key.pub"

    "/etc/machine-id"
  ];

  environment = {
    systemPackages = with pkgs; [
      bottom
      nix-index
      skim
      tealdeer
      coreutils-full
      direnv
      ripgrep
      ripgrep-all
      tealdeer
      fd
      fzf
      bat
      exa
      file
      pulsemixer
      procs
      tokei
      jq
      manix
      git
      neovim
      nixos-option
      dogdns

      man-db
      man-pages
      man-pages-posix
      stdmanpages
    ];

    shellInit = ''
      export STARSHIP_CONFIG=${
        pkgs.writeText "starship.toml"
        (fileContents ./starship.toml)
      }
    '';

    shellAliases =
      let ifSudo = lib.mkIf config.security.sudo.enable;
      in
      {
        # exa
        ls = "exa --group-directories-first";
        l = "exa -1";
        ll = "exa -lg";
        la = "exa -la";

        g = "git";
        ps = "procs";
        top = "btm";

        # internet ip
        myip = "dog myip.opendns.com @208.67.222.222";

        # nix
        mn = ''
          manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' |  sk --preview='manix {}' | sed "s/'/\\\\'/g" | xargs manix
        '';

        # fix nixos-option
        nixos-option = "nixos-option -I nixpkgs=${self}/lib/compat";

        # systemd
        ctl = "systemctl";
        stl = ifSudo "sudo systemctl";
      };
  };

  fonts = {
    fonts = with pkgs; [ powerline-fonts dejavu_fonts ];

    fontconfig.defaultFonts = {
      monospace = [ "DejaVu Sans Mono for Powerline" ];
      sansSerif = [ "DejaVu Sans" ];
    };
  };

  # Set timezone and locale
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Berlin";

  nix = {
    autoOptimiseStore = true;
    gc.automatic = true;
    optimise.automatic = true;

    useSandbox = true;

    allowedUsers = [ "@wheel" ];
    trustedUsers = [ "root" "@wheel" ];

    extraOptions = ''
      min-free = 536870912
      keep-outputs = true
      keep-derivations = true
      fallback = true
    '';

  };

  # Configure zsh shell.
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    shellInit = ''
      if [ "$0" = "zsh-no-vim" ]; then
        bindkey -e
      else
        bindkey -v
      fi
    '';

    promptInit = ''
      eval "$(${pkgs.starship}/bin/starship init zsh)"
    '';
  };

  # For rage encryption, all hosts need a ssh key pair
  services.openssh = {
    enable = true;
    openFirewall = lib.mkDefault false;
  };

  services.earlyoom.enable = true;
}
