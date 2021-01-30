{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    package = pkgs.neovim;
    extraPackages = with pkgs; [ gcc nixfmt curl rust-analyzer ];

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    withPython = true;

    plugins = with pkgs.vimPlugins; [
      # Color theme
      nord-vim

      vim-sneak
      vim-rooter
      nerdcommenter
      neoformat
      vim-crates
      vim-eunuch

      vim-terraform

      nvim-treesitter

      nvim-lspconfig
      lsp_extensions-nvim

      plenary-nvim
      popup-nvim
      telescope-nvim
    ];

    extraConfig = ''
      luafile ~/.config/nvim/init.lua
    '';
  };

  # Home Manager doesn't have a way to provide a lua config
  # using `extraConfig` so we just link it manually
  xdg.configFile."nvim/init.lua".source = ./init.lua;

  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.MANPAGER = "nvim +Man!";
}
