-- This module is the initialising module
-- and is responsible for setting up the whole
-- neovim configuration.

-- Setup core mappings
local mappings = require("core.mappings")
mappings.core()
mappings.lsp()

-- Load options and autocmd
require("core.options")
require("core.autocmd")

-- Load plugin configurations
local exists = require("core.utils").exists;

-- Load theme
if exists("nord") then
  vim.o.background = "dark"
  require("nord").set()
end

function load_if_present(c, mod)
  if exists(c) then
    require(mod)
  end
end

if exists("telescope") then
  mappings.telescope()
end

require("plugins.neoterm")

load_if_present("nvim-treesitter", "plugins.treesitter")
load_if_present("gitsigns", "plugins.gitsigns")
load_if_present("presence", "plugins.presence")

load_if_present("cmp", "plugins.cmp")
load_if_present("lspconfig", "plugins.lspconfig")
