{ pkgs, ... }:
let
  inherit (builtins) readFile;

  neovim-nightly = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: {
    version = "v0.5.0-nightly";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "0a95549d66df63c06d775fcc329f7b63cbb46b2f";
      sha256 = "0000000000000000000000000000000000000000000000000000";
    };
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

    plugins = with pkgs.vimPlugins; [
      nord-vim
      vim-sneak
      vim-rooter
      nerdcommenter
      vim-polyglot
      fzf-vim
      vim-crates
      neoformat

      # Language server client
      nvim-lspconfig
      lsp_extensions-nvim
      completion-nvim
    ];

    extraConfig = (readFile ./lsp.vim) + (readFile ./init.vim);
  };
}
