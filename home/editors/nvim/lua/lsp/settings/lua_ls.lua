local lspconfig = require("lspconfig")
local lsp = require("lsp-zero")

local config = {
  settings = {
    Lua = {
      format = {
        enable = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
}

lspconfig.lua_ls.setup(vim.tbl_deep_extend("force", lsp.nvim_lua_ls(), config))
