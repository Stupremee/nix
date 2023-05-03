local status_ok, lsp = pcall(require, "lsp-zero")
if not status_ok then
  return
end

lsp.preset({
  name = "recommended",
  set_lsp_keymaps = { omit = { "<F2>", "<F4>" } },
  cmp_opts = {
    sources = {
      { name = "copilot" },
    },
  },
})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({ buffer = bufnr })

  local opts = { buffer = bufnr }

  vim.keymap.set("n", "ga", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "gR", vim.lsp.buf.rename, opts)

  if client.supports_method("textDocument/formatting") then
    vim.keymap.set({ "n", "x" }, "gq", function()
      vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
    end, opts)

    vim.api.nvim_create_autocmd("BufWritePre", {
      desc = "Auto format before save",
      pattern = "<buffer>",
      callback = function()
        vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
      end,
    })
  end
end)

lsp.skip_server_setup({ "rust-analyzer" })
local rust_lsp = lsp.build_options("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      lens = {
        enabled = true,
      },
      checkOnSave = {
        command = "clippy",
      },
    },
  },
})

-- Load all servers
require("user.lsp.settings.volar")
require("user.lsp.settings.tailwindcss")
require("user.lsp.settings.tsserver")
require("user.lsp.settings.lua_ls")

lsp.configure({
  "nil_ls",
  "taplo",
  "terraformls",
  "jsonls",
  "prismals",
  "graphql",
  "svelte",
})

lsp.setup()

local status_ok2, rust_tools = pcall(require, "rust-tools")
if status_ok2 then
  rust_tools.setup({
    inlay_hints = {
      auto = false,
    },
    server = rust_lsp,
  })
end

local null_ls = require("null-ls")
local null_opts = lsp.build_options("null-ls", {})

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
  sources = {
    formatting.alejandra,
    formatting.stylua,
    formatting.prettierd,
    formatting.black,
    formatting.xmllint,

    diagnostics.deadnix,
    diagnostics.flake8,
    diagnostics.eslint_d,
  },
  on_attach = function(client, bufnr)
    null_opts.on_attach(client, bufnr)
  end,
})

local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
    return false
  end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

local cmp = require("cmp")
cmp.setup({
  mapping = {
    ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
    ["<Tab>"] = vim.schedule_wrap(function(fallback)
      if cmp.visible() and has_words_before() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      else
        fallback()
      end
    end),
  },
})
