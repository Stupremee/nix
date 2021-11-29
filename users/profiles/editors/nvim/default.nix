{ pkgs, lib, config, ... }: {
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      curl

      # Language servers
      rust-analyzer
      rnix-lsp

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
      nerdcommenter
      vim-eunuch
      neoterm
      gitsigns-nvim
      editorconfig-vim
      nvim-bufdel

      ### Syntax highlighting
      nvim-treesitter

      ### Fuzzy searching
      plenary-nvim
      popup-nvim
      telescope-nvim

      ## Language server
      vim-vsnip
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-path
      cmp-vsnip

      ## Extra language support
      rust-tools-nvim
    ];

    extraConfig = ''
      lua << EOF
        ${builtins.readFile ./init.lua}
      EOF
    '';
  };

  # Link lua directory into nvim config directory
  # xdg.configFile."nvim/lua".source = ./lua;

  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.MANPAGER = "nvim +Man!";
}
