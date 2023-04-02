local status_ok, lsp = pcall(require, "lsp-zero")
if not status_ok then
	return
end

lsp.preset({
	name = "recommended",
	set_lsp_keymaps = { omit = { "<F2>", "<F4>" } },
})
lsp.nvim_workspace()

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

lsp.configure("nil_ls")
lsp.configure("taplo")
lsp.configure("terraformls")
-- lsp.configure("eslint")
lsp.configure("jsonls")
lsp.configure("lua_ls")
lsp.configure("prismals")

lsp.on_attach(function(_, bufnr)
	local opts = { buffer = bufnr }

	vim.keymap.set("n", "ga", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "gR", vim.lsp.buf.rename, opts)

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
end)

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
