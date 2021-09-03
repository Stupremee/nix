local scopes = {o = vim.o, b = vim.bo, w = vim.wo}

local function opt(scope, key, value)
    scopes[scope][key] = value
    if scope ~= "o" then scopes["o"][key] = value end
end

opt("o", "statusline", "%=%m %l:%c %p%% %f")

local indent = 4

opt("o", "hidden", true)
opt("o", "scrolloff", 4)
opt("o", "shiftround", true)
opt("o", "sidescrolloff", 8)
opt("o", "smartcase", true) 
opt("o", "splitbelow", true)
opt("o", "splitright", true)
opt("o", "cmdheight", 2)
opt("o", "termguicolors", true)
opt("o", "updatetime", 1000)

opt("o", "undodir", "/home/stu/.cache/vimdid")
opt("b", "undofile", true)

opt("b", "expandtab", true)
opt("b", "shiftwidth", indent)
opt("b", "smartindent", true)
opt("b", "tabstop", indent)

opt("w", "cursorline", true)
opt("w", "number", true)
opt("w", "relativenumber", true)
opt("w", "wrap", false)
opt("w", "signcolumn", "yes")
