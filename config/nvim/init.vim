" Set leader keys
let g:mapleader="\<Space>"
filetype plugin indent on
syntax on

" Set colortheme
set background=dark
colorscheme nord

" Set custom statusline
set laststatus=2
set statusline=%=%m\ %c\ %P\ %f

" Some general settings
set encoding=utf-8
set ttyfast
set ttimeout
set ttimeoutlen=50
set backspace=indent,eol,start
set showcmd
set wildmenu
set hidden
set nowrap
set number
set relativenumber
set cursorline
set splitbelow
set splitright
set autoindent
set incsearch
set hlsearch
set ignorecase
set smartcase
set cmdheight=2
set updatetime=300
set signcolumn=yes

" Set tab size
set tabstop=4
set softtabstop=0
set expandtab
set shiftwidth=2
set smarttab

" Permanent undo history
set undodir=~/.cache/vimdid
set undofile

let g:netrw_dirhistmax = 0

" ------------------
" Plugin settings
" ------------------

"augroup fmt
    "autocmd BufWritePre * Neoformat
"augroup END

inoremap <silent><expr> <c-space> coc#refresh()

if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

if has('nvim')
  autocmd BufRead Cargo.toml call crates#toggle()
endif

au BufRead,BufNewFile *.dl set filetype=dl

" ------------------
" Shortcuts
" ------------------

" Fuzzy finding
map <C-p> :Files<CR>
nmap <leader>; :Buffers<CR>
nmap <leader>ss :Rg<CR>

" C-h stops the search
nnoremap <C-h> :nohlsearch<CR>

" Suspend vim
nnoremap <C-f> :sus<CR>

" Clipboard integration
noremap <leader>p "+p<CR>
noremap <leader>c "+y<CR>

" Format buffer
"nmap <leader>f :Neoformat<CR>

nmap <silent> [e <Plug>(coc-diagnostic-prev)
nmap <silent> ]e <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> <leader>cd <Plug>(coc-definition)
nmap <silent> <leader>ct <Plug>(coc-type-definition)
nmap <silent> <leader>cI <Plug>(coc-implementation)
nmap <silent> <leader>cD <Plug>(coc-references)
nmap <leader>ac :CocAction<CR>

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for do codeAction of selected region
function! s:cocActionsOpenFromSelected(type) abort
  execute 'CocCommand actions.open ' . a:type
endfunction
xmap <silent> <leader>a :<C-u>execute 'CocCommand actions.open ' . visualmode()<CR>
nmap <silent> <leader>a :<C-u>set operatorfunc=<SID>cocActionsOpenFromSelected<CR>g@

" Symbol renaming.
nmap <leader>cr <Plug>(coc-rename)
