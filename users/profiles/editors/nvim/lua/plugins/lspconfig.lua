local nvim_lsp = require("lspconfig")

local opts = {
    -- rust-tools options
    tools = { 
        autoSetHints = true,
        hover_with_actions = true,
        inlay_hints = {
            show_parameter_hints = false,
            parameter_hints_prefix = "",
            other_hints_prefix = "",
        },
    },

    -- all the opts to send to nvim-lspconfig
    server = {},
}

require("rust-tools").setup(opts)
