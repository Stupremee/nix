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

lsp.configure("tailwindcss")
lsp.configure("nil_ls")
lsp.configure("taplo")
lsp.configure("terraformls")
lsp.configure("eslint")
lsp.configure("jsonls")
lsp.configure("lua_ls")
lsp.configure("tsserver")

lsp.on_attach(function(client, bufnr)
	vim.keymap.set("n", "ga", vim.lsp.buf.code_action, { buffer = bufnr })
	vim.keymap.set("n", "gR", vim.lsp.buf.rename, { buffer = bufnr })

	if client.supports_method("textDocument/formatting") then
		vim.api.nvim_create_autocmd("BufWritePre", {
			desc = "Auto format before save",
			pattern = "<buffer>",
			callback = function()
				if vim.fn.exists(":NullFormat") > 0 then
					vim.cmd(":NullFormat")
				else
					vim.cmd(":LspZeroFormat")
				end
			end,
		})
	end
end)

lsp.setup()

local status_ok, rust_tools = pcall(require, "lsp-zero")
if status_ok then
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

		diagnostics.deadnix,
		diagnostics.flake8,
	},
	on_attach = function(client, bufnr)
		null_opts.on_attach(client, bufnr)

		local format_cmd = function(input)
			vim.lsp.buf.format({
				id = client.id,
				timeout_ms = 5000,
				async = input.bang,
			})
		end

		vim.api.nvim_buf_create_user_command(bufnr, "NullFormat", format_cmd, {
			bang = true,
			range = true,
			desc = "Format of current buffer",
		})
	end,
})
