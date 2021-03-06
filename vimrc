call pathogen#runtime_append_all_bundles()

call pathogen#helptags()

let s:current_file = expand("<sfile>:p")

set nowrap

filetype off
filetype plugin indent on
syntax on

" remember last position in file
" see :help last-position-jump
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g`\"" | endif
endif

" Treat JSON files like JavaScript
au BufNewFile,BufRead *.json set ft=javascript

au BufNewFile,BufRead *.textile set ft=textile
au BufNewFile,BufRead *.less set ft=less

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

"set paste
let mapleader = ";"

" Show arrows in nerdtree
let NERDTreeDirArrows=1

nmap <Leader>n :NERDTreeToggle<CR>
nmap <Leader>w :w<CR>
nmap <Leader><Leader> :ZoomWin<CR>

" The single greatest human achievement
nnoremap <Leader> :

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

" Command-T configuration
let g:CommandTMaxHeight=20


" IMPORTANT: Uncomment one of the following lines to force
" " using 256 colors (or 88 colors) if your terminal supports it,
" " but does not automatically use 256 colors by default.
set t_Co=256
" "set t_Co=88
let g:CSApprox_attr_map = ( 'bold')

:set laststatus=2
" Status line ------------------------------------------------------------- {{{

augroup ft_statuslinecolor
  au!

  au InsertEnter * hi StatusLine ctermfg=196 guifg=#E8E11C
  au InsertLeave * hi StatusLine ctermfg=130 guifg=#687778
augroup END

set statusline=%f    " Path.
set statusline+=%m   " Modified flag.
set statusline+=%r   " Readonly flag.
set statusline+=%w   " Preview window flag.

set statusline+=\    " Space.

set statusline+=%=   " Right align.

" File format, encoding and type.  Ex: "(unix/utf-8/python)"
set statusline+=(Type\: 
set statusline+=%{&ft}                        " Type (python).
set statusline+=)

" }}}

" Create Blank Newlines and stay in Normal mode
nnoremap <silent> zj o<Esc>
nnoremap <silent> zk O<Esc>

" Space will toggle folds!
nnoremap <space> za

" Incremental searching is sexy
set incsearch

" Highlight things that we find with the search
set hlsearch

" Line Numbers PWN!
set number

" Ignoring case is a fun trick
set ignorecase

" And so is Artificial Intellegence!
set smartcase

let delimitMate_expand_cr = 1

set background=dark
color rdark

set nobackup
set nowritebackup
set noswapfile

" Be certain these two lines have no trailing spaces
" Rehighlight visual block after left/right shift
vnoremap < <gv
vnoremap > >gv

" We have a big repository, sadly enough
let g:CommandTMaxFiles=50000
" Make delete work as backspace
"let g:CommandTBackspaceMap='<Del>'

set mouse=a

nnoremap <leader>gd :Gdiff<cr>
nnoremap <leader>gs :Gstatus<cr>
nnoremap <leader>gw :Gwrite<cr>
nnoremap <leader>ga :Gadd<cr>
nnoremap <leader>gb :Gblame<cr>
nnoremap <leader>gco :Gcheckout<cr>
nnoremap <leader>gci :Gcommit<cr>
nnoremap <leader>gm :Gmove<cr>
nnoremap <leader>gr :Gremove<cr>
nnoremap <leader>gl :Shell git gl -18<cr>:wincmd \|<cr>

noremap  <buffer> <silent> k gk
noremap  <buffer> <silent> j gj
noremap  <buffer> <silent> 0 g0
noremap  <buffer> <silent> $ g$


" Split/Join {{{
"
" Basically this splits the current line into two new ones at the cursor
" position,
" then joins the second one with whatever comes next.
"
" Example:                      Cursor Here
"                                    |
"                                    V
" foo = ('hello', 'world', 'a', 'b', 'c',
"        'd', 'e')
"
"            becomes
"
" foo = ('hello', 'world', 'a', 'b',
"        'c', 'd', 'e')
"
" Especially useful for adding items in the middle of long lists/tuples in
" Python
" while maintaining a sane text width.
nnoremap K h/[^ ]<cr>"zd$jyyP^v$h"zpJk:s/\v +$//<cr>:noh<cr>j^
" }}}}
" 
" Auto save when we go elsewhere
"au FocusLost * :wa

source $DOTFILES/private/*.vim
