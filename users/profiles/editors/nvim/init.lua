local scopes = {o = vim.o, b = vim.bo, w = vim.wo}

local function opt(scope, key, value)
    scopes[scope][key] = value
    if scope ~= "o" then scopes["o"][key] = value end
end

local function exists(mod)
  local present, _ = pcall(require, mod)
  return present
end

local function map(mode, keys, cmd, opt)
   local options = { noremap = true, silent = true }
   if opt then
      options = vim.tbl_extend("force", options, opt)
   end

   -- all valid modes allowed for mappings
   -- :h map-modes
   local valid_modes = {
      [""] = true,
      ["n"] = true,
      ["v"] = true,
      ["s"] = true,
      ["x"] = true,
      ["o"] = true,
      ["!"] = true,
      ["i"] = true,
      ["l"] = true,
      ["c"] = true,
      ["t"] = true,
   }

   -- helper function for M.map
   -- can gives multiple modes and keys
   local function map_wrapper(mode, lhs, rhs, options)
      if type(lhs) == "table" then
         for _, key in ipairs(lhs) do
            map_wrapper(mode, key, rhs, options)
         end
      else
         if type(mode) == "table" then
            for _, m in ipairs(mode) do
               map_wrapper(m, lhs, rhs, options)
            end
         else
            if valid_modes[mode] and lhs and rhs then
               vim.api.nvim_set_keymap(mode, lhs, rhs, options)
            else
               mode, lhs, rhs = mode or "", lhs or "", rhs or ""
               print("Cannot set mapping [ mode = '" .. mode .. "' | key = '" .. lhs .. "' | cmd = '" .. rhs .. "' ]")
            end
         end
      end
   end

   map_wrapper(mode, keys, cmd, options)
end

opt("o", "statusline", "%=%m %l:%c %p%% %f")

local indent = 4

opt("o", "hidden", true)
opt("o", "scrolloff", 4)
opt("o", "sidescrolloff", 8)
opt("o", "shiftround", true)
opt("o", "smartcase", true)
opt("o", "cmdheight", 2)
opt("o", "termguicolors", true)
opt("o", "splitbelow", true)
opt("o", "splitright", true)
opt("o", "exrc", true)

opt("b", "undofile", true)
opt("b", "expandtab", true)
opt("b", "shiftwidth", indent)
opt("b", "tabstop", indent)
opt("b", "smartindent", true)

opt("w", "cursorline", true)
opt("w", "number", true)
opt("w", "relativenumber", true)
opt("w", "wrap", false)
opt("w", "signcolumn", "yes")

-- Enable yank highlighting
vim.cmd [[ au TextYankPost * lua vim.highlight.on_yank {on_visual = false} ]]

-- Auto format on save
vim.cmd [[ autocmd BufWritePre * lua vim.lsp.buf.formatting_sync() ]]

-- Show diagnostic popup on cursor hold
vim.cmd [[ autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics() ]]

--
-- Keybind mappings
--
vim.g.mapleader = ' '

-- C-h stops the search
map("n", "<C-h>", ":noh<CR>")

-- Suspend neovim
map("n", "<C-f>", ":sus<CR>")

if exists("telescope") then
  map("n", "<leader>ff", ":Telescope find_files<CR>")
  map("n", "<leader>fb", ":Telescope buffers<CR>")
  map("n", "<leader>fs", ":Telescope live_grep<CR>")
  map("n", "<leader>fp", ":Telescope projects<CR>")
  map("n", "<leader>fa", ":Telescope lsp_code_actions<CR>")
end

--
-- Plugin settings
--

-- Set theme
if exists("nord") then
  vim.o.background = "dark"
  require("nord").set()
end

-- Neoterm settings
vim.api.nvim_set_var("neoterm_shell", "zsh-no-vim")

-- Gitsigns
if exists("gitsigns") then
  require("gitsigns").setup { keymaps = {} }
end

-- Treesitter
if exists("nvim-treesitter.configs") then
  require("nvim-treesitter.configs").setup {
    highlight = { enable = true },
    indent = { enable = true }
  }
end

-- nvim-cmp
if exists("cmp") then
  local cmp = require("cmp")

  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      end,
    },
    mapping = {
      -- Completion item navigation
      ["<Up>"] = cmp.mapping.select_prev_item(),
      ["<Down>"] = cmp.mapping.select_next_item(),
      ["<C-e>"] = cmp.mapping.close(),
      ["<CR>"] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Insert,
        select = true,
      }),
      -- Scroll docs
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
    },

    -- Installed sources
    sources = {
      { name = "nvim_lsp" },
      { name = "vsnip" },
      { name = "path" },
    },
  })
end

-- lspconfig and rust-tools
if exists("rust-tools") then
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

    server = {},
  }

  require("rust-tools").setup(opts)
end

if exists("lspconfig") then
  local nvim_lsp = require("lspconfig")

  nvim_lsp.rnix.setup{}
end
