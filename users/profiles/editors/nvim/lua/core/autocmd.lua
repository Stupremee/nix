-- Enable yank highlighting
vim.cmd [[ au TextYankPost * lua vim.highlight.on_yank {on_visual = false} ]]

-- Auto format on save
vim.cmd [[ autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync() ]]

-- Manually set some filetypes
vim.cmd [[ au BufRead,BufNewFile *.tf set ft=terraform ]]
vim.cmd [[ au BufRead,BufNewFile *.nix set ft=nix ]]

-- Show diagnostic popup on cursor hold
vim.cmd [[ autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics() ]]
