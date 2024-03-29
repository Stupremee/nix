local status_ok, _ = pcall(require, "nvim-treesitter")
if not status_ok then
  return
end

local _, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  return
end

local dir = vim.fn.stdpath("cache") .. "/treesitter"

vim.opt.runtimepath:append(dir)

configs.setup({
  parser_install_dir = dir,

  ensure_installed = { "rust", "nix", "lua" },
  ignore_install = {},
  sync_install = false,
  auto_install = true,

  highlight = {
    enable = true,
    disable = {},
  },

  autopairs = { enable = true },

  indent = {
    enable = true,
    disable = { "nix", "yuck" },
  },

  autotag = {
    enable = true,
  },
})

local status_ok2, comment = pcall(require, "ts_context_commentstring")
if not status_ok2 then
  return
end

comment.setup({})
vim.g.skip_ts_context_commentstring_module = true
