{
  unstable-pkgs,
  lib,
  theme,
  ...
}: let
  pkgs = unstable-pkgs;

  base64-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "base64-nvim";
    version = "67fb5f1";
    src = pkgs.fetchFromGitHub {
      owner = "moevis";
      repo = "base64.nvim";
      rev = "67fb5f12db252b3e2bd190250d3edbed7aa8d3aa";
      sha256 = "sha256-eByAH1iy7Px/AhtA6FzMPgP56TgaR0p+UumXrHmlbuU=";
    };
  };

  extraPackages = with unstable-pkgs; [
    gcc
    tree-sitter

    # formatters
    alejandra
    stylua

    # linters
    deadnix

    # language servers
    rust-analyzer
    rnix-lsp
    sumneko-lua-language-server
    taplo-lsp
    terraform-ls
    nodePackages.bash-language-server
    shellcheck
  ];

  config = pkgs.neovimUtils.makeNeovimConfig {
    withPython3 = true;
    withRuby = true;
    withNodeJs = true;

    viAlias = true;
    vimAlias = true;

    plugins = map (x: {plugin = x;}) (with pkgs.vimPlugins; [
      impatient-nvim
      catppuccin-nvim

      nvim-cmp
      cmp-path
      cmp-buffer
      cmp-nvim-lua
      cmp-nvim-lsp
      cmp_luasnip

      nvim-lspconfig
      null-ls-nvim
      vim-illuminate
      rust-tools-nvim

      luasnip
      friendly-snippets

      nvim-treesitter
      nvim-ts-context-commentstring
      yuck-vim

      nvim-web-devicons
      vim-bbye
      telescope-nvim
      gitsigns-nvim
      nvim-autopairs
      comment-nvim
      nvim-tree-lua
      bufferline-nvim
      lualine-nvim
      project-nvim
      indent-blankline-nvim
      base64-nvim
    ]);

    customRC = ''
      :lua require("user.impatient")
      :lua require("user.options")
      :lua require("user.keymaps")
      :lua require("user.autocommands")

      :lua require("user.colorscheme")
      :Catppuccin ${theme.name}

      :lua require("user.cmp")
      :lua require("user.telescope")
      :lua require("user.gitsigns")
      :lua require("user.treesitter")
      :lua require("user.autopairs")
      :lua require("user.comment")
      :lua require("user.nvimtree")
      :lua require("user.bufferline")
      :lua require("user.lualine")
      :lua require("user.project")
      :lua require("user.illuminate")
      :lua require("user.indentline")
      :lua require("user.alpha")
      :lua require("user.lsp")
    '';
  };

  neovim =
    pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped
    (config
      // {
        wrapperArgs = (lib.escapeShellArgs config.wrapperArgs) + " --suffix PATH : \"${lib.makeBinPath extraPackages}\"";
        wrapRc = false;
      });
in {
  home.packages = [neovim pkgs.nvimpager];

  home.sessionVariables.EDITOR = "${neovim}/bin/nvim";
  home.sessionVariables.MANPAGER = "${pkgs.nvimpager}/bin/nvimpager";

  xdg.configFile."nvim/init.vim".text = config.neovimRcContent;

  xdg.configFile."nvim/ftplugin" = {
    recursive = true;
    source = ./ftplugin;
  };

  xdg.configFile."nvim/lua/user" = {
    recursive = true;
    source = ./lua;
  };
}
