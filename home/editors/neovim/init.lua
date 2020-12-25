-- Neovim configuration written in Lua

-- `cmd` can execute any vim command
local cmd = vim.cmd
-- `fn` can be used to call vim functions
local fn = vim.fn
-- access to global variables
local g = vim.g

-- Set leader key
g.mapleader = ' '

-- Configure filetype
cmd 'filetype plugin indent on'
cmd 'syntax on'

-- Set the colorscheme
vim.o.background = 'dark'
cmd 'colorscheme nord'

-- Enable vim-crates
cmd 'autocmd BufRead Cargo.toml call crates#toggle()'

--------------------------------------
-- Set vim options
--------------------------------------
vim.o.statusline = '%=%m %c %P %f'

vim.o.encoding = 'utf-8'
vim.o.ttimeoutlen = 50
vim.o.backspace = 'indent,eol,start'
vim.o.wrap = false

vim.o.number = true
vim.o.relativenumber = true

vim.o.cursorline = true
vim.o.autoindent = true

vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.cmdheight = 2
vim.o.signcolumn = 'yes'

-- Indentation size
local indent = 4
vim.o.shiftwidth = indent
vim.o.tabstop = indent

vim.o.smarttab = true
vim.o.expandtab = true

-- Undo settings
vim.o.undodir = '~/.cache/vimdid'
vim.o.undofile = true

--------------------------------------
-- Treesitter configuration
--------------------------------------
--require'nvim-treesitter.configs'.setup {
  --ensure_installed = "maintained",
  --highlight = {
    --enable = true,
  --},
  --indent = {
    --enable = true
  --}
--}

--vim.o.foldmethod = 'expr'
--vim.o.foldexpr = 'nvim_treesitter#foldexpr()'

--------------------------------------
-- Language Server Configuration
--------------------------------------
local lsp = require 'lspconfig'

-- menuone: popup even when there's only one match
-- noinsert: Do not insert text until a selection is made
-- noselect: Do not select, force user to select one from the menu
vim.o.completeopt = 'menuone,noinsert,noselect'

lsp.rust_analyzer.setup {}
lsp.terraformls.setup {}

vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false,
    signs = true,
    update_in_insert = false,
  }
)

-- These things can get really anoying
-- cmd 'autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostic()'

-- Inlay hints
cmd "autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost * lua require'lsp_extensions'.inlay_hints{ prefix = '', highlight = 'Comment' }"

--------------------------------------
-- Keybinds
--------------------------------------
local function map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Fuzzy finding keybinds
map('n', '<leader>ff', '<cmd>Telescope find_files<CR>')
map('n', '<leader>fb', '<cmd>Telescope buffers<CR>')
map('n', '<leader>fs', '<cmd>Telescope live_grep<CR>')

-- C-h stops the search
map('n', '<C-h>', '<cmd>nohlsearch<CR>')

-- Suspend neovim
map('n', '<C-f>', '<cmd>sus<CR>')

-- LSP keybindings

map('n', '[e', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
map('n', ']e', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')

map('n', '<leader>ld', '<cmd>lua vim.lsp.buf.definition()<CR>')
map('n', '<leader>lt', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
map('n', '<leader>lI', '<cmd>lua vim.lsp.buf.implementation()<CR>')
map('n', '<leader>lD', '<cmd>lua vim.lsp.buf.references()<CR>')
map('n', '<leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>')
map('n', '<leader>lK', '<cmd>lua vim.lsp.buf.hover()<CR>')

--------------------------------------
-- Some more stuff
--------------------------------------

-- Enable yank highlighting
cmd 'au TextYankPost * lua vim.highlight.on_yank {on_visual = false}'

-- Auto format on save
cmd 'au BufWritePre * Neoformat'
