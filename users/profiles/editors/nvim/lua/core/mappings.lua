local utils = require("core.utils")
local map = utils.map

local M = {}

-- The core keybinds that work without any plugins
M.core = function()
  -- Set the leader key
  vim.g.mapleader = ' '

  -- C-h stops the search
  map("n", "<C-h>", ":noh<CR>")

  -- Suspend neovim
  map("n", "<C-f>", ":sus<CR>")

end

-- Keybinds for telescope.nvim. Common prefix is <leader>f
M.telescope = function() 
  print("hi")
  map("n", "<leader>ff", ":Telescope find_files<CR>")
  map("n", "<leader>fb", ":Telescope buffers<CR>")
  map("n", "<leader>fs", ":Telescope live_grep<CR>")
  map("n", "<leader>fp", ":Telescope projects<CR>")
  map("n", "<leader>fa", ":Telescope lsp_code_actions<CR>")
end

-- Keybinds for lsp
M.lsp = function()
  map("n", "g[", ":lua vim.lsp.diagnostic.goto_prev()<CR>")
  map("n", "g]", ":lua vim.lsp.diagnostic.goto_next()<CR>")
end

return M
