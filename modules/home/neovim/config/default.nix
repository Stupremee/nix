{ pkgs, lib, theme, ... }:
let
  inherit (lib.generators) mkLuaInline;
in
{
  vim = {
    extraPackages = with pkgs; [
      gitlab-ci-ls
      yamlfmt
    ];

    viAlias = false;
    vimAlias = true;

    additionalRuntimePaths = [ ./nvim ];

    options = {
      tabstop = 4;
      shiftwidth = 4;
    };

    theme = {
      enable = true;
      name = "catppuccin";
      style = theme;
    };

    undoFile.enable = true;

    keymaps = [
      {
        key = "<leader>?";
        mode = "n";
        silent = true;
        action = ":Cheatsheet<CR>";
      }
      {
        key = "<leader>e";
        mode = "n";
        silent = true;
        action = ":Neotree toggle<CR>";
      }
      {
        key = "<leader>h";
        mode = "n";
        silent = true;
        action = ":nohlsearch<CR>";
      }
    ];

    spellcheck = {
      enable = true;
    };

    formatter.conform-nvim = {
      enable = true;
      setupOpts.formatters_by_ft = {
        terraform = [
          "tofu_fmt"
          "terraform_fmt"
        ];
        yaml = [ "yamlfmt" ];
        "yaml.gitlab" = [ "yamlfmt" ];
      };
    };

    autocmds = [
      {
        desc = "Set filetype to GitLab CI file";
        pattern = [ "*.gitlab-ci*.{yml,yaml}" ];
        event = [
          "BufRead"
          "BufNewFile"
        ];
        callback = mkLuaInline ''
          function() 
            vim.bo.filetype = "yaml.gitlab"
          end
        '';
      }
    ];

    lsp = {
      formatOnSave = true;
      lspkind.enable = false;
      lightbulb.enable = true;
      lspsaga.enable = false;
      trouble.enable = true;
      lspSignature.enable = true;

      lspconfig.sources = {
        gitlab_ci_ls = ''
          require'lspconfig'.gitlab_ci_ls.setup{}
        '';
      };
    };

    treesitter = {
      grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        just
      ];
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
      terraform.enable = true;
      svelte.enable = true;
      ts = {
        enable = true;
        extensions.ts-error-translator.enable = true;
      };

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
        activeSection.b = [
          ''
            {
              "filetype",
              colored = true,
              icon_only = true,
              icon = { align = 'left' }
            }
          ''
          ''
            {
              "filename",
              symbols = {modified = ' ', readonly = ' '},
              separator = {right = ''}
            }
          ''
          ''
            {
              "macro",
              fmt = function()
                local reg = vim.fn.reg_recording()
                if reg ~= "" then
                  return "recording @" .. reg
                end
                return nil
              end,
              draw_empty = false,
              colored = true,
              separator = { left = '', right = '' }
            }
          ''
        ];
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
      nvimBufferline = {
        enable = true;

        mappings = {
          closeCurrent = "<leader>bd";
          cycleNext = "L";
          cyclePrevious = "H";
        };

        setupOpts.options = {
          numbers = "none";
          indicator.style = "none";
        };
      };
    };

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
      alpha = {
        enable = true;
        theme = "theta";
      };
    };

    notify = {
      nvim-notify.enable = true;
    };

    projects = {
      project-nvim.enable = true;
    };

    session.nvim-session-manager = {
      enable = true;
      setupOpts = {
        autoload_mode = "CurrentDir";
      };
    };

    utility = {
      ccc.enable = true;
      diffview-nvim.enable = true;
      icon-picker.enable = true;
      surround.enable = true;

      motion = {
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
      breadcrumbs.enable = false;

      smartcolumn.enable = true;
      fastaction.enable = true;
    };

    assistant = {
      chatgpt.enable = false;

      copilot = {
        enable = true;
        mappings.suggestion = {
          accept = "<M-f>";
          prev = "<M-p>";
          next = "<M-n>";
        };

        setupOpts.suggestion = {
          enabled = true;
          auto_trigger = true;
        };
      };

      codecompanion-nvim.enable = false;
    };

    comments = {
      comment-nvim.enable = true;
    };
  };
}
