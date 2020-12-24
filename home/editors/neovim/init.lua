-- Neovim configuration written in Lua

-- `cmd` can execute any vim command
local cmd = vim.cmd
-- `fn` can be used to call vim functions
local fn = vim.fn
-- access to global variables
local g = vim.g

-- enable deoplete on startup
g['deoplete#enable_at_startup'] = 1

-- helper function to set a vim option
local scopes = {
  o = vim.o,
  b = vim.bo,
  w = vim.wo
}

local function opt(scope, key, value)
  scopes[scope][key] = value
  if scope ~= 'o' then scopes['o'][key] = value end
end



