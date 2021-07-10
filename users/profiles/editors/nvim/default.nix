{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.editors.nvim;
in
{
  options.modules.editors.nvim = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      extraPackages = with pkgs; [
        nixpkgs-fmt
        curl

        # Language servers
        rust-analyzer
        zls

        # Required for building tree-sitter grammars
        tree-sitter
        nodejs
        python3
        gnumake
        gcc
        binutils
      ];

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      plugins = with pkgs.vimPlugins; [
        ### Styling
        nord-nvim
        github-nvim-theme

        ### Utilities
        vim-sneak
        vim-rooter
        nerdcommenter
        neoformat
        vim-eunuch
        vim-hexokinase
        presence-nvim

        ### Syntax highlighting
        nvim-treesitter

        ### Fuzzy searching
        plenary-nvim
        popup-nvim
        telescope-nvim
        # snap

        ### Language support
        # ale
        zig-vim

        ### Language server support
        nvim-compe
        nvim-lspconfig
      ];

      extraConfig = ''
        lua <<EOF
          ${builtins.readFile ./init.lua}
        EOF
      '';
    };

    home.sessionVariables.EDITOR = "nvim";
    home.sessionVariables.MANPAGER = "nvim +Man!";
  };
}
