{ ... }:
{
  vim = {
    viAlias = false;
    vimAlias = true;

    theme = {
      enable = true;
      name = "catppuccin";
      style = "frappe";
    };

    spellcheck = {
      enable = true;
    };

    lsp = {
      formatOnSave = true;
      lspkind.enable = false;
      lightbulb.enable = true;
      lspsaga.enable = false;
      trouble.enable = true;
      lspSignature.enable = true;
    };

    languages = {
      enableLSP = true;
      enableFormat = true;
      enableTreesitter = true;
      enableExtraDiagnostics = true;

      nix = {
        enable = true;
        format.type = "nixfmt";
      };

      markdown.enable = true;
      bash.enable = true;

      rust = {
        enable = true;
        crates.enable = true;
      };
    };

    visuals = {
      nvim-scrollbar.enable = true;
      nvim-web-devicons.enable = true;
      nvim-cursorline.enable = true;
      cinnamon-nvim.enable = true;
      fidget-nvim.enable = true;

      highlight-undo.enable = true;
      indent-blankline.enable = true;
    };

    statusline = {
      lualine = {
        enable = true;
      };
    };

    autopairs.nvim-autopairs.enable = true;

    autocomplete.nvim-cmp.enable = true;
    snippets.luasnip.enable = true;

    filetree = {
      neo-tree = {
        enable = true;
      };
    };

    tabline = {
      nvimBufferline.enable = true;
    };

    treesitter.context.enable = true;

    binds = {
      whichKey.enable = true;
      cheatsheet.enable = true;
    };

    telescope.enable = true;

    git = {
      enable = true;
      gitsigns.enable = true;
      gitsigns.codeActions.enable = false;
    };

    dashboard = {
      alpha.enable = true;
    };

    notify = {
      nvim-notify.enable = true;
    };

    projects = {
      project-nvim.enable = true;
    };

    utility = {
      ccc.enable = true;
      diffview-nvim.enable = true;
      icon-picker.enable = true;
      surround.enable = true;

      motion = {
        hop.enable = true;
        leap.enable = true;

        # Cool plugin, but a bit annoying
        precognition.enable = false;
      };
    };

    notes = {
      todo-comments.enable = true;
    };

    ui = {
      borders.enable = true;
      noice.enable = true;
      colorizer.enable = true;
      illuminate.enable = true;

      breadcrumbs = {
        enable = true;
      };

      smartcolumn = {
        enable = true;
        setupOpts.custom_colorcolumn = {
          nix = "110";
          ruby = "120";
          java = "130";
          go = [
            "90"
            "130"
          ];
        };
      };

      fastaction.enable = true;
    };

    assistant = {
      chatgpt.enable = false;

      copilot = {
        enable = false;
        cmp.enable = false;
      };

      codecompanion-nvim.enable = false;
    };

    comments = {
      comment-nvim.enable = true;
    };
  };
}
