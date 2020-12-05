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

augroup fmt
  autocmd BufWritePre * Neoformat
augroup END

if has('nvim')
  autocmd BufRead Cargo.toml call crates#toggle()
endif

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
nmap <leader>f :Neoformat<CR>
