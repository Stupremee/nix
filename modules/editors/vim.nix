{ config, options, lib, pkgs, ... }:
with lib;
{
  options.modules.editors.vim = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.editors.vim.enable {
    my = {
      packages = with pkgs; [
        nodejs
        xsel
        editorconfig-core-c
        (
          neovim.override {
            configure = {
              customRC = lib.readFile <config/nvim/init.vim>;
              packages.myNeovimPackage = with pkgs.vimPlugins; {
                start = [
                  nord-vim
                  vim-sneak
                  vim-rooter
                  neoformat
                  nerdcommenter
                  vim-polyglot
                  vim-nix
                  vim-fugitive
                  fzf-vim
                  nerdtree
                  nerdtree-git-plugin

                  unstable.pkgs.vimPlugins.vim-crates

                  unstable.pkgs.vimPlugins.coc-nvim
                  coc-git
                  unstable.pkgs.vimPlugins.coc-rust-analyzer
                ];
              };
            };
          }
        )
      ];

      alias.vim = "nvim";
      alias.v = "nvim";
    };
  };
}
