{ pkgs, ... }:
let
  inherit (builtins) readFile;

  neovim-nightly = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: {
    version = "f75be5e";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      # Commit where builtin diagnostics feature was introduced
      rev = "f75be5e9d510d5369c572cf98e78d9480df3b0bb";
      sha256 = "sha256-kGMAUWs1N3SCGvzaiLRihXacI9BGNWPAjaXiBDH8ON4=";
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

    extraConfig = (readFile ./lsp.vim) + (readFile ./init.vim);
  };

  home.sessionVariables.MANPAGER = "nvim +Man!";
}
