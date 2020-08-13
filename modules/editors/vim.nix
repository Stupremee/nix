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
                  fzf-vim
                  vim-polyglot
                  vim-nix
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
