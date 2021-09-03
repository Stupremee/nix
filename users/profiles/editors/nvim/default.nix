{ pkgs, lib, config, ... }: {
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      curl

      # Formatting tools
      nixpkgs-fmt

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
      editorconfig-vim

      ### Syntax highlighting
      nvim-treesitter

      ### Fuzzy searching
      plenary-nvim
      popup-nvim
      telescope-nvim

      ## Language server
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-vsnip
      cmp-path

      ## Extra language support
      rust-tools-nvim
    ];

    extraConfig = ''
      lua require("core")
    '';
  };

  # Link lua directory into nvim config directory
  xdg.configFile."nvim/lua".source = ./lua;

  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.MANPAGER = "nvim +Man!";
}
