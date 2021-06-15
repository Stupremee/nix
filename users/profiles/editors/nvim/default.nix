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
      package = pkgs.neovim;
      extraPackages = with pkgs; [
        nixpkgs-fmt
        curl

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
        # Color theme
        nord-nvim

        vim-sneak
        vim-rooter
        nerdcommenter
        neoformat
        vim-eunuch
        vim-hexokinase

        vim-terraform
        nvim-treesitter

        plenary-nvim
        popup-nvim
        telescope-nvim

        ale
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
