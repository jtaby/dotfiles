filetype off
filetype plugin indent on

set nocompatible 

" Use 2 spaces instead of tabs
set tabstop=2
set softtabstop=2 
set shiftwidth=2
set expandtab

set scrolloff=3

set showmode
set showcmd 

set wildmenu
set wildmode=list:longest,full

set backspace=2 whichwrap+=<,>,[,],h,l " backspace and cursor keys wrap to prev/next line

set fileformat=unix
set encoding=utf-8

set paste

set history=50
set nowrap "Don't screen-wrap my code by default. 
set nu "line numbers

set ttyfast

set backup " make backups
set backupdir=~/.vim/backup
set directory=/tmp " for temp files

set visualbell
set cursorline

" share the unnamed register with the clipboard so when you yank in vim, you can paste in some other application with the middle click, and vice versa
set clipboard+=unnamed 

set laststatus=2 
set guioptions-=T

" Always change to the directory the file in your current buffer is in
""au BufEnter * :cd %:p:h
au FocusLost * :wa

" Leader
let mapleader = ";"

" Selection
nnoremap / /\v
vnoremap / /\v
set ignorecase
set smartcase
set incsearch
set showmatch 
set hlsearch 
map <leader><space> :noh<cr>
map <leader>d :cd %:p:h<cr>
runtime macros/matchit.vim
nmap <tab> %
vmap <tab> %

" Easy buffer navigation
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" map ctrl-left ctrl-right to move to next/prev buffers
" fix for console/terminal first, though
map Oc <C-Right>
map Od <C-Left>
noremap <C-Right> :bn<CR>
noremap <C-Left> :bp<CR>

" The single greatest human achievement
nnoremap ; :

" Be certain these two lines have no trailing spaces
" Rehighlight visual block after left/right shift
vnoremap < <gv
vnoremap > >gv

"make it so that jk, instead of navigating across actual lines, allows you
"to scroll up/down visual lines... so if you have a really long wrapped line,
"you can actually scroll down through it
nnoremap <Down> gj
nnoremap <Up> gk

"cycle through open buffer windows, whether split horizontally or vertically,
"similar to alt-tab. also see set wiw and set wh for more usefulness, below.
map <C-N> <C-W>w

" swap the word the cursor is on with the next word (which can be on a newline, and punctuation is 'skipped'):
nmap <silent> gw "_yiw:s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<CR><C-o>:noh<CR>

syntax on
colorscheme molokai

" select in visual mode, press * and voila, you're searching for that phrase!
" note that this differs from the normal-mode use of * in that you can phrase-search
vmap * :<C-U>let old_reg=@"<cr>gvy/<C-R><C-R>=substitute(escape(@",'\\/.*$^~[]'),"\\n$","","")<CR><CR>:let @"=old_reg<CR>

let b:delimitMate_expand_cr = "\<CR>\<CR>\<Up>\<Tab>"

" Mappings
inoremap ;; <Esc>
imap <C-t> <Esc>

let $VIMRUNTIME="/Users/majd/.vim/"
