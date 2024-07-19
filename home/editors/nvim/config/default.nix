{
  pkgs,
  packages,
  ...
}: {
  imports = [
    ./options.nix
    ./keymap.nix

    ./colorschemes/catppuccin.nix

    ./completion/cmp.nix
    ./completion/copilot.nix
    ./completion/lspkind.nix
    ./completion/luasnip.nix

    ./bufferlines/bufferline.nix
    ./filetrees/nvim-tree.nix

    ./git/gitsigns.nix
    ./git/diffview.nix

    ./languages/nvim-lint.nix
    ./languages/treesitter.nix
    ./languages/typescript-tools-nvim.nix

    ./lsp/conform.nix
    ./lsp/fidget.nix
    ./lsp/lsp.nix
    ./lsp/lspsaga.nix
    ./lsp/trouble.nix

    ./ui/notify.nix
    ./ui/alpha.nix
    ./ui/dressing.nix
    ./ui/indent-blankline.nix
    ./ui/noice.nix
    ./ui/nui.nix

    ./statusline/lualine.nix
    ./telescope/telescope.nix

    ./utils/illuminate.nix
    ./utils/markdown-preview.nix
    ./utils/mini.nix
    ./utils/neodev.nix
    ./utils/nvim-colorizer.nix
    ./utils/todo-comments.nix
    ./utils/nvim-autopairs.nix
    ./utils/undotree.nix
    ./utils/whichkey.nix
  ];

  extraPackages = with pkgs; [
    ripgrep

    # formatters and linters
    statix
    ruff
    selene
    alejandra

    # language servers
    rust-analyzer
    nodePackages.eslint_d
    nodePackages.typescript-language-server
    nodePackages.svelte-language-server
    vue-language-server
    packages."@fsouza/prettierd"
    packages."@tailwindcss/language-server"
    packages."vscode-langservers-extracted"
  ];
}
