{ pkgs, ... }:
let
  inherit (builtins) readFile;

  neovim-nightly = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: {
    version = "nightly";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "nightly";
      sha256 = "sha256-01PIRQRI1PDTvIG5bpuDTnHrrqX+JtsdM8WWQIrWXMc=";
    };
    nativeBuildInputs = oldAttrs.nativeBuildInputs
      ++ [ pkgs.utf8proc pkgs.unstable.tree-sitter ];
  });
in {
  programs.neovim = {
    enable = true;
    package = neovim-nightly;
    extraPackages = with pkgs; [ gcc nixfmt curl terraform-ls rust-analyzer ];

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
      vim-eunuch

      # Universal syntax highlighting
      nvim-treesitter

      # Language Server Plugins
      nvim-lspconfig
      lsp_extensions-nvim

      # Fuzzy finding
      plenary-nvim
      popup-nvim
      telescope-nvim
    ];

    extraConfig = ''
      luafile ~/.config/nvim/init.lua
    '';
    # extraConfig = (readFile ./init.vim) + (readFile ./lsp.vim);
  };

  # Home Manager doesn't have a way to provide lua config using `extraConfig`.
  # So we just link it normally.
  xdg.configFile."nvim/init.lua".source = ./init.lua;
  home.sessionVariables.MANPAGER = "nvim +Man!";
}
