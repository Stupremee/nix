{ unstable-pkgs
, lib
, theme
, ...
}:
let
  pkgs = unstable-pkgs;

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

    plugins = map (x: { plugin = x; }) (with pkgs.vimPlugins; [
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
    ]);

    customRC = ''
      :lua require("user.impatient")
      :lua require("user.options")
      :lua require("user.keymaps")
      :lua require("user.autocommands")

      let g:catppuccin_flavor = "${theme.name}"
      :lua require("user.colorscheme")

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
in
{
  home.packages = [ neovim pkgs.nvimpager ];

  home.sessionVariables.EDITOR = "${neovim}/bin/nvim";
  home.sessionVariables.MANPAGER = "${pkgs.nvimpager}/bin/nvimpager";
  home.sessionVariables.PAGER = "${pkgs.nvimpager}/bin/nvimpager";

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
