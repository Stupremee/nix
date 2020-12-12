{ pkgs, ... }:
let
  inherit (builtins) readFile;

  neovim-nightly = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: {
    version = "nightly";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "nightly";
      sha256 = "sha256-NwPf19cCVJVcP3QBp0h0aOtHbdW/7HmFGFEyBB3BBrM=";
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

    plugins = with pkgs.vimPlugins;
      [
        nord-vim
        vim-sneak
        vim-rooter
        nerdcommenter
        vim-polyglot
        fzf-vim
        vim-crates
        neoformat

      ] ++ (with pkgs.unstable.vimPlugins; [
        # Language server client
        nvim-lspconfig
        lsp_extensions-nvim
        completion-nvim
      ]);

    extraConfig = (readFile ./init.vim) + (readFile ./lsp.vim);
  };

  home.sessionVariables.MANPAGER = "nvim +Man!";
}
