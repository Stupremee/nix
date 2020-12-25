{ pkgs, ... }:
let
  inherit (builtins) readFile;

  neovim-nightly = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: {
    version = "nightly";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "nightly";
      sha256 = "sha256-mpeNUoDFA+U9bjmeyYVzTOitoUkTE6JA9csmhIDkzPc=";
    };
    nativeBuildInputs = oldAttrs.nativeBuildInputs
      ++ [ pkgs.utf8proc pkgs.unstable.tree-sitter ];
  });
in {
  home.packages = with pkgs; [ curl nixfmt ];

  programs.neovim = {
    enable = true;
    package = neovim-nightly;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    withPython = false;

    plugins = with pkgs.unstable.vimPlugins; [
      # Color theme
      nord-vim

      # Various Utilities
      vim-sneak
      vim-rooter
      nerdcommenter
      neoformat
      vim-crates

      # Universal syntax highlighting
      nvim-treesitter

      # Language Server Plugins
      deoplete-lsp
      deoplete-nvim
      nvim-lspconfig

      # Fuzzy finding
      fzf-vim
      telescope-nvim
    ];

    # extraConfig = (readFile ./init.lua);
    # extraConfig = (readFile ./init.vim) + (readFile ./lsp.vim);
  };

  home.sessionVariables.MANPAGER = "nvim +Man!";
}
