syntax on

set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set number
set nowrap
set smartcase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set backspace=indent,eol,start " backspace over everything in insert mode

set colorcolumn=80
highlight ColorColumn ctermbg=0 guibg=lightgrey
highlight Todo cterm=bold ctermfg=red

call plug#begin('~/.vim/plugged')
Plug 'morhetz/gruvbox'
Plug 'jremmen/vim-ripgrep'
Plug 'tpope/vim-fugitive'
Plug 'leafgarland/typescript-vim'
"Plug 'vim-utils/vim-man'
"Plug 'lyuts/vim-rtags'
"Plug 'git@github.com:kien/ctrlp.vim.git'
Plug 'mbbill/undotree'
Plug 'frazrepo/vim-rainbow'  
"if has('patch-8.1.2269')                                                                                                                                                                                
    " Latest YCM needs at least this version of vim                                                                                                                                                     
"    Plug 'ycm-core/YouCompleteMe'                                                                                                                                                                       
"else                                                                                                                                                                                                    
    " Version compatible with the vim in Debian 10 buster                                                                                                                                               
"    Plug 'ycm-core/YouCompleteMe', { 'commit':'d98f896' }                                                                                                                                               
"endif
call plug#end()

"colorscheme zellner
colorscheme gruvbox
set background=dark
  
