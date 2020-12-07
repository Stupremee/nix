" menuone: popup even when there's only one match
" noinsert: Do not insert text until a selection is made
" noselect: Do not select, force user to select one from the menu
set completeopt=menuone,noinsert,noselect
set shortmess+=c

lua << EOF
local lspconfig = require'lspconfig'

local on_attach = function(client)
    require'completion'.on_attach(client)
end

-- Rust Analyzer
lspconfig.rust_analyzer.setup({ on_attach=on_attach })

-- Terraform
lspconfig.terraformls.setup({ on_attach=on_attach })
EOF

" Run completion on <TAB>
inoremap <silent><expr> <TAB>
  \ pumvisible() ? "\<C-n>" :
  \ <SID>check_back_space() ? "\<TAB>" :
  \ completion#trigger_completion()

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction

nnoremap <silent> [e            <cmd>vim.lsp.diagnostic.goto_prev()<cr>
nnoremap <silent> ]e            <cmd>vim.lsp.diagnostic.goto_next()<cr>

nnoremap <silent> <leader>cd    <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> <leader>ct    <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> <leader>cI    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <leader>cD    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> K             <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> <leader>a     <cmd>lua vim.lsp.buf.code_action()<CR>

" Diagnostic configuration
lua << EOF
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false,
    signs = true,
    update_in_insert = false,
  }
)
EOF

autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()

" Inlay hints
autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *
  \ lua require'lsp_extensions'.inlay_hints{ prefix = '', highlight = "Comment" }

