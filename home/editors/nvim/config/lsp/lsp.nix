{pkgs, ...}: {
  extraPlugins = with pkgs.vimPlugins; [
    neoconf-nvim
  ];

  plugins = {
    lsp = {
      enable = true;
      capabilities = "capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true";
      servers = {
        lua-ls = {
          enable = true;
          extraOptions = {
            settings = {
              Lua = {
                completion = {
                  callSnippet = "Replace";
                };
                telemetry = {
                  enabled = false;
                };
                hint = {enable = true;};
              };
            };
          };
        };

        pyright.enable = true;
        ruff-lsp.enable = true;

        volar.enable = true;
        svelte.enable = true;
        tailwindcss.enable = true;
        jsonls.enable = true;

        rust-analyzer = {
          enable = true;
          installCargo = false;
          installRustc = false;
          settings = {
            checkOnSave = true;
            check = {
              command = "clippy";
            };

            # inlayHints = {
            #   enable = true;
            #   showParameterNames = true;
            #   parameterHintsPrefix = "<- ";
            #   otherHintsPrefix = "=> ";
            # };
            procMacro = {
              enable = true;
            };
          };
        };
      };
    };
  };

  extraConfigLuaPre = ''
    require("neoconf").setup({})
  '';

  extraConfigLua = ''
    local _border = "rounded"

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
      vim.lsp.handlers.hover, {
        border = _border
      }
    )

    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
      vim.lsp.handlers.signature_help, {
        border = _border
      }
    )

    vim.diagnostic.config{
      float={border=_border}
    };

    require('lspconfig.ui.windows').default_options = {
      border = _border
    }
  '';
}
