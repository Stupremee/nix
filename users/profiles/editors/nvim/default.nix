{ pkgs, lib, config, ... }: {
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      nixpkgs-fmt
      curl

      # Language servers
      rust-analyzer
      zls

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
      ### Styling
      nord-nvim

      ### Utilities
      vim-sneak
      nerdcommenter
      neoformat
      vim-eunuch
      presence-nvim
      neoterm
      gitsigns-nvim
      project-nvim
      editorconfig-vim

      ### Syntax highlighting
      nvim-treesitter

      ### Fuzzy searching
      plenary-nvim
      popup-nvim
      telescope-nvim

      ### Language support
      zig-vim

      ### Language server support
      nvim-compe
      nvim-lspconfig
    ];

    extraConfig = ''
      lua <<EOF
        ${builtins.readFile ./init.lua}
      EOF
    '';
  };

  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.MANPAGER = "nvim +Man!";
}
