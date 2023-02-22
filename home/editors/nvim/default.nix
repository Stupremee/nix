{
  unstable-pkgs,
  lib,
  theme,
  packages,
  inputs,
  system,
  ...
}: let
  pkgs = unstable-pkgs;

  extraPackages = with pkgs; [
    gcc
    tree-sitter

    # formatters
    alejandra
    stylua

    # linters
    deadnix

    # language servers
    packages."@volar/vue-language-server"
    packages."@tailwindcss/language-server"
    packages."vscode-langservers-extracted"
    packages."@fsouza/prettierd"
    inputs.nil.packages."${system}".default
    rust-analyzer
    taplo-lsp
    terraform-ls
    lua-language-server
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

      nvim-lspconfig
      packages.lsp-zero-nvim

      nvim-cmp
      cmp-path
      cmp-buffer
      cmp-nvim-lua
      cmp-nvim-lsp
      cmp_luasnip

      luasnip
      friendly-snippets

      null-ls-nvim
      vim-illuminate
      rust-tools-nvim

      nvim-treesitter
      nvim-ts-context-commentstring
      nvim-ts-autotag
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
      packages.base64-nvim
      packages.dressing-nvim
    ]);

    customRC = ''
      let g:typescript_server_path = "${pkgs.nodePackages.typescript}/lib/node_modules/typescript/lib"

      :lua require("user.impatient")
      :lua require("user.options")
      :lua require("user.keymaps")
      :lua require("user.autocommands")

      :lua require("user.colorscheme")
      :Catppuccin ${theme.name}

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
      :lua require("user.dressing")
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
