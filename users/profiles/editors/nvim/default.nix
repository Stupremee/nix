{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    package = pkgs.neovim;
    extraPackages = with pkgs; [
      nixpkgs-fmt
      curl
      rust-analyzer

      # Required for building tree-sitter grammars
      tree-sitter
      nodejs
      python3
      gnumake
      gcc
      binutils
    ];

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      # Color theme
      nord-nvim

      vim-sneak
      vim-rooter
      nerdcommenter
      neoformat
      vim-eunuch
      vim-hexokinase

      vim-terraform
      nvim-treesitter

      plenary-nvim
      popup-nvim
      telescope-nvim
    ];

    extraConfig = ''
      lua <<EOF
        ${builtins.readFile ./init.lua}
      EOF
    '';
  };

  # Home Manager doesn't have a way to provide a lua config
  # using `extraConfig` so we just link it manually
  # xdg.configFile."nvim/init.lua".source = ./init.lua;

  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.MANPAGER = "nvim +Man!";
}
