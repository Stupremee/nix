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
        bc
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
                  nerdcommenter
                  vim-polyglot
                  vim-nix
                  fzf-vim

                  unstable.pkgs.vimPlugins.vim-crates
                  unstable.pkgs.vimPlugins.coc-nvim
                  unstable.pkgs.vimPlugins.coc-rust-analyzer
                  coc-json
                ];
              };
            };
          }
        )
      ];

      home.xdg.configFile."nvim/coc-settings.json".source = <config/nvim/coc-settings.json>;


      alias.vim = "nvim";
      alias.v = "nvim";
    };
  };
}
