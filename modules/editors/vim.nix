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
              plug.plugins = with pkgs.vimPlugins; [
                nord-vim
                vim-sneak
                vim-rooter
                neoformat
                nerdcommenter
                fzf-vim
                vim-polyglot
                vim-nix
                vim-fugitive

                coc-nvim
                coc-git
              ];
            };
          }
        )
      ];

      alias.vim = "nvim";
      alias.v = "nvim";
    };
  };
}
