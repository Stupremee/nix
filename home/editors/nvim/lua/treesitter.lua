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

	context_commentstring = {
		enable = true,
		enable_autocmd = false,
	},

	autotag = {
		enable = true,
	},
})
