{
  unstable-pkgs,
  lib,
  theme,
  packages,
  ...
}: let
  pkgs = unstable-pkgs;

  extraPackages = with pkgs; [
    gcc
    tree-sitter
    ripgrep

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
    packages."@prisma/language-server"
    packages."graphql-language-service-cli"
    packages."vscode-smarty-langserver-extracted"
    packages."svelte-language-server"
    nodePackages.typescript-language-server
    nodePackages.eslint_d
    rust-analyzer
    gopls
    taplo-lsp
    terraform-ls
    lua-language-server
    python310Packages.flake8
    python310Packages.black
    libxml2 # for xmllint
    phpactor
    php82Packages.php-cs-fixer
    php82Packages.php-codesniffer
  ];

  config = pkgs.neovimUtils.makeNeovimConfig {
    withPython3 = true;
    withRuby = true;
    withNodeJs = true;

    viAlias = true;
    vimAlias = true;

    plugins = map (x: {plugin = x;}) (with packages; [
      plenary-nvim
      impatient-nvim
      catppuccin-nvim

      nvim-lspconfig
      lsp-zero-nvim

      nvim-cmp
      cmp-path
      cmp-buffer
      cmp-nvim-lua
      cmp-luasnip
      cmp-nvim-lsp
      lua-snip
      neoconf-nvim

      copilot-lua

      none-ls-nvim
      vim-illuminate
      rust-tools-nvim

      nvim-treesitter
      nvim-ts-context-commentstring
      nvim-ts-autotag
      todo-comments-nvim

      nvim-tree-lua
      nvim-web-devicons

      vim-bbye
      telescope-nvim
      gitsigns-nvim
      nvim-autopairs
      comment-nvim
      bufferline-nvim
      lualine-nvim
      indent-blankline-nvim
      base64-nvim
      dressing-nvim
      # nvim-notify
      move-nvim
      nui-nvim
      noice-nvim
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
      :lua require("user.todo-comments")
      :lua require("user.autopairs")
      :lua require("user.comment")
      :lua require("user.nvimtree")
      :lua require("user.bufferline")
      :lua require("user.lualine")
      :lua require("user.illuminate")
      :lua require("user.indentline")
      :lua require("user.alpha")
      :lua require("user.dressing")
      :lua require("user.lsp")
      :lua require("user.copilot")
      :lua require("user.notify")
      :lua require("user.move")
      :lua require("user.noice")
    '';
  };

  neovim =
    pkgs.wrapNeovimUnstable (pkgs.neovim-unwrapped.override {treesitter-parsers = {};})
    (config
      // {
        wrapperArgs = (lib.escapeShellArgs config.wrapperArgs) + " --suffix PATH : \"${lib.makeBinPath extraPackages}\"";
        wrapRc = false;
      });
in {
  home.packages = [neovim];

  home.sessionVariables = {
    EDITOR = "${neovim}/bin/nvim";
    MANPAGER = "${neovim}/bin/nvim +Man!";
  };

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
