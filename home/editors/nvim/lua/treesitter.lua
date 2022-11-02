local status_ok, treesitter = pcall(require, "nvim-treesitter")
if not status_ok then
	return
end

local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
	return
end

local dir = vim.fn.stdpath("cache").. "/treesitter"

vim.opt.runtimepath:append(dir)

configs.setup({
  parser_install_dir = dir,

  ensure_installed = { "rust", "nix", "lua" },
	ignore_install = { },
	sync_install = false,
  auto_install = true,
  
  highlight = {
		enable = true,
		disable = { },
	},

	autopairs = { enable = true, },

	indent = {
    enable = true,
    disable = { }
  },

	context_commentstring = {
		enable = true,
		enable_autocmd = false,
	},
})
