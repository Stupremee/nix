local util = require("lspconfig.util")

local function is_vue_project(startpath)
	return util.root_pattern("nuxt.config.ts", "app.vue")(startpath)
end

require("lsp-zero").configure("tsserver", {
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},
	root_dir = function(fname)
		if not is_vue_project(fname) then
			return util.root_pattern("tsconfig.json")(fname)
				or util.root_pattern("package.json", "jsconfig.json", ".git")(fname)
		end
	end,
	single_file_support = false,
})
