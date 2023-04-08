require("harpoon").setup({
  -- sets the marks upon calling `toggle` on the ui, instead of require `:w`.
  save_on_toggle = false,
  -- saves the harpoon file upon every change. disabling is unrecommended.
  save_on_change = true,
  -- sets harpoon to run the command immediately as it's passed to the terminal when calling `sendCommand`.
  enter_on_sendcmd = false,
  -- closes any tmux windows harpoon that harpoon creates when you close Neovim.
  tmux_autoclose_windows = false,
  -- filetypes that you want to prevent from adding to the harpoon list menu.
  excluded_filetypes = { "harpoon" },
  -- set marks specific to each git branch inside git repository
  mark_branch = false,
})

local keymap = vim.keymap.set
local opts = { silent = true }

keymap("n", "<leader>hh", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>", opts)
keymap("n", "<leader>ha", "<cmd>lua require('harpoon.mark').add_file()<CR>", opts)

-- keymap("n", "<leader>hn", "<cmd>lua require('harpoon.mark').nav_next()<CR>", opts)
-- keymap("n", "<leader>hp", "<cmd>lua require('harpoon.mark').nav_prev()<CR>", opts)

keymap("n", "<S-l>", "<cmd>lua require('harpoon.ui').nav_next()<CR>", opts)
keymap("n", "<S-h>", "<cmd>lua require('harpoon.ui').nav_prev()<CR>", opts)
