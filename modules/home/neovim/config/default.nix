{
  pkgs,
  lib,
  theme,
  ...
}:
let
  inherit (lib.generators) mkLuaInline;

  ctrlAlt = if pkgs.stdenv.isDarwin then "C" else "M";
in
{
  vim = {
    package = pkgs.unstable.neovim-unwrapped;

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
      {
        key = "<leader>aa";
        mode = [
          "n"
          "v"
        ];
        silent = true;
        action = ":CodeCompanionActions<CR>";
        desc = "CodeCompanion Actions";
      }
      {
        key = "<leader>ac";
        mode = [
          "n"
          "v"
        ];
        silent = true;
        action = ":CodeCompanionChat Toggle<CR>";
        desc = "CodeCompanion Chat";
      }
      {
        key = "<leader>ad";
        mode = "v";
        silent = true;
        action = ":CodeCompanionChat Add<CR>";
        desc = "CodeCompanion Chat Add";
      }
    ];

    spellcheck = {
      enable = true;
    };

    lazy.plugins = {
      "nlsp-settings.nvim" = {
        package = pkgs.vimPlugins.nlsp-settings-nvim;
        setupModule = "nlspsettings";
        setupOpts = {
          config_home = mkLuaInline ''vim.fn.stdpath('config') .. "/nlsp-settings" '';
          local_settings_dir = ".nlsp-settings";
          local_settings_root_markers_fallback = [ ".git" ];
          append_default_schemas = true;
          loader = "json";
        };
      };

      "supermaven-nvim" = {
        package = pkgs.vimPlugins.supermaven-nvim;
        setupModule = "supermaven-nvim";
        setupOpts = {
          keymaps = {
            accept_suggestion = "<${ctrlAlt}-f>";
            clear_suggestion = "<${ctrlAlt}-e>";
            accept_word = "<${ctrlAlt}-w>";
          };
        };
      };

      codecompanion-nvim.after = ''
        vim.cmd([[cab cc CodeCompanion]])
      '';
    };

    pluginRC.conform-nvim = lib.mkAfter ''
      require("conform").formatters.rustfmt = {
        options = {
          default_edition = "2024"
        },
      }
    '';

    formatter.conform-nvim = {
      enable = true;
      setupOpts = {
        formatters_by_ft = {
          terraform = [
            "tofu_fmt"
            "terraform_fmt"
          ];
          yaml = [ "yamlfmt" ];
          "yaml.gitlab" = [ "yamlfmt" ];
        };
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

        opentofu-ls = ''
          lspconfig.tofu_ls.setup {
            capabilities = capabilities,
            on_attach=default_on_attach,
            cmd = {"${pkgs.unstable.opentofu-ls}/bin/opentofu-ls", "serve"},
          }
        '';
      };
    };

    treesitter = {
      grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        just
      ];
    };

    lsp.enable = true;

    languages = {
      enableFormat = true;
      enableTreesitter = true;
      enableExtraDiagnostics = true;

      nix = {
        enable = true;
        format.type = "nixfmt";
        lsp.enable = false;
      };

      markdown.enable = true;
      yaml.enable = true;
      bash.enable = true;
      terraform = {
        enable = true;
        lsp.enable = false;
      };
      svelte.enable = true;
      ts = {
        enable = true;
        extensions.ts-error-translator.enable = true;
      };
      php.enable = true;

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
          accept = "<${ctrlAlt}-f>";
          prev = "<${ctrlAlt}-p>";
          next = "<${ctrlAlt}-n>";
        };

        setupOpts.suggestion = {
          enabled = false;
          auto_trigger = true;
        };
      };

      codecompanion-nvim.enable = true;
    };

    comments = {
      comment-nvim.enable = true;
    };
  };
}
