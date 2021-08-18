-- Neovim configuration written in Lua

-- `cmd` can execute any vim command
local cmd = vim.cmd
-- `fn` can be used to call vim functions
local fn = vim.fn
-- access to global variables
local g = vim.g

-- Set leader key
g.mapleader = ' '

-- Set ripgrep for vimgrep search
g.grepprg = 'rg --vimgrep'

-- Configure filetype
cmd 'filetype plugin indent on'
cmd 'syntax on'

-- Set the colorscheme
vim.o.background = 'dark'
require('nord').set()

--require("github-theme").setup({
    --themeStyle = "light";
--})

--------------------------------------
-- Set vim options
--------------------------------------
local scopes = {o = vim.o, b = vim.bo, w = vim.wo}

local function opt(scope, key, value)
    scopes[scope][key] = value
    if scope ~= 'o' then scopes['o'][key] = value end
end

opt('o', 'statusline', '%=%m %l:%c %p%% %f')

local indent = 4

opt('o', 'hidden', true)
opt('o', 'ignorecase', true)
opt('o', 'joinspaces', false)
opt('o', 'scrolloff', 4)
opt('o', 'shiftround', true)
opt('o', 'sidescrolloff', 8)
opt('o', 'smartcase', true) 
opt('o', 'splitbelow', true)
opt('o', 'splitright', true)
opt('o', 'wildmode', 'longest:full,full')
opt('o', 'cmdheight', 2)
opt('o', 'termguicolors', true)

opt('o', 'undodir', '/home/stu/.cache/vimdid')
cmd 'set undofile'

opt('b', 'expandtab', true)
opt('b', 'shiftwidth', indent)
opt('b', 'smartindent', true)
opt('b', 'tabstop', indent)

opt('w', 'cursorline', true)
opt('w', 'number', true)
opt('w', 'relativenumber', true)
opt('w', 'wrap', false)
opt('w', 'signcolumn', 'yes')

--------------------------------------
-- Plugin configuration
--------------------------------------

-- Neoterm
vim.api.nvim_set_var("neoterm_shell", "bash")

-- Treesitter
require'nvim-treesitter.configs'.setup {
    -- ensure_installed = "maintained",
    highlight = {
        enable = true,
    },
    indent = {
        enable = false
    }
}

-- gitsigns
require('gitsigns').setup {
    -- do not provide any keybinds
    keymaps = {}
}

-- project.nvim
require("project_nvim").setup {
    silent_chdir = false,
}
require('telescope').load_extension('projects')

-- presence.nvim
require("presence"):setup({
    -- General options
    auto_update         = true,
    neovim_image_text   = "Neovim",
})

--------------------------------------
-- Language Server Configuration
--------------------------------------

-- menuone: popup even when there's only one match
-- noselect: Do not select, force user to select one from the menu
vim.o.completeopt = 'menuone,noselect'

local enable_completion = true

if enable_completion then
    require'compe'.setup {
        enabled = true;
        autocomplete = true;
        debug = false;
        min_length = 1;
        preselect = 'enable';
        throttle_time = 80;
        source_timeout = 200;
        resolve_timeout = 800;
        incomplete_delay = 400;
        max_abbr_width = 100;
        max_kind_width = 100;
        max_menu_width = 100;
        documentation = true;
        
        source = {
            path = true;
            nvim_lsp = true;
            nvim_lua = true;
        };
    }

    -- Activate language servers
    require'lspconfig'.rust_analyzer.setup{}

    require'lspconfig'.zls.setup{}
end

--------------------------------------
-- Keybinds
--------------------------------------
local function map(mode, lhs, rhs, opts)
    local options = {noremap = true}
    if opts then options = vim.tbl_extend('force', options, opts) end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

local function map_expr(mode, lhs, rhs, opts)
    local options = {noremap = true, expr = true}
    if opts then options = vim.tbl_extend('force', options, opts) end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- language server keybindings
map_expr('i', '<C-Space>', 'compe#complete()')
map_expr('i', '<CR>', 'compe#confirm(\'<CR>\')')
map_expr('i', '<C-e>', 'compe#close(\'<C-e>\')')

-- Fuzzy finding keybinds
map('n', '<leader>ff', '<cmd>Telescope find_files<CR>')
map('n', '<leader>fb', '<cmd>Telescope buffers<CR>')
map('n', '<leader>fs', '<cmd>Telescope live_grep<CR>')
map('n', '<leader>fp', '<cmd>Telescope projects<CR>')
map('n', '<leader>fa', '<cmd>Telescope lsp_code_actions<CR>')

-- C-h stops the search
map('n', '<C-h>', '<cmd>nohlsearch<CR>')

-- Suspend neovim
map('n', '<C-f>', '<cmd>sus<CR>')

--------------------------------------
-- Some more stuff
--------------------------------------

-- Enable yank highlighting
cmd 'au TextYankPost * lua vim.highlight.on_yank {on_visual = false}'

-- Auto format on save
cmd 'au BufWritePre * Neoformat'

-- Manually set some filetypes
cmd 'au BufRead,BufNewFile *.tf set ft=terraform'
cmd 'au BufRead,BufNewFile *.nix set ft=nix'
