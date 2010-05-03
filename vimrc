" Disable vi compatibility to enable extended vim features
" Note that this isn't really necessary, as the use of a ~/.vimrc sets this automatically
set nocompatible 

let cpo_save=&cpo
set cpo=B

if filereadable( expand( expand( "<sfile>:h") . "/.vimrc.web") )
:source <sfile>:h/.vimrc.web
endif

" Always change to the directory the file in your current buffer is in
au BufEnter * :cd %:p:h
set hlsearch

" map 'F9' to toggle un/wrapping the text lines
noremap <F9> :set wrap!<CR>
" make vim wrap long lines at a character in 'breakat' rather than the last char that fits on the screen
set linebreak
set is "DO highlight while typing search characters

" map ctrl-left ctrl-right to move to next/prev buffers
" fix for console/terminal first, though
map Oc <C-Right>
map Od <C-Left>
noremap <C-Right> :bn<CR>
noremap <C-Left> :bp<CR>

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

" Resize this 'window' according to the number of lines in it (nothing to do
" with the window manager window.)
map <M--> :exe "resize ". line("$")<CR>mxgg'x

" Debug your syntax highlighting
map <M-i> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") ."> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

map Q gq
let &cpo=cpo_save
unlet cpo_save

let perl_extended_vars=1
set path=.,/usr/include/,/usr/lib/perl5,*.pm,, " include Perl in path for '|gf|' and ':find' 
set backspace=2 whichwrap+=<,>,[,],h,l " backspace and cursor keys wrap to prev/next line
set listchars=tab:>-,trail:-,eol:$
set fileformat=unix
set history=50
"set iskeyword=!-~,^*,^|,^\"
set ruler
set showcmd
set viminfo='20,\"50
set nowrap "Don't screen-wrap my code by default. 
set nu "line numbers
set backup " make backups
set backupdir=~/.vim/backup
set directory=/tmp " for temp files
set wildmenu
set wildmode=list:longest,full
set showmatch " show matching brackets
set mat=5 " blink match for x 10ths of a second
set textwidth=0
set expandtab " expand tab chars to spaces by default
set tabstop=2 " tabspacing
set softtabstop=2 " 
set shiftwidth=2 " indenting 
set popt=number:y,wrap:y,syntax:n,portrait:n
set pfn=monaco:h8 " The name of the font that will be used for :hardcopy
" remove octal if you don't want 017 to increment to 020 ;)
set nrformats=octal,hex,alpha " allow us to increment letters as well as numbers via  and 
" share the unnamed register with the clipboard so when you yank in vim, you can paste in some other application with the middle click, and vice versa
set clipboard+=unnamed 

set wiw=80 " minimal window height and width when switching.
" removed. added MiniBufExplorer from vim.org which gets awkward with this
"set wh=23

" this must appear before syntax/filetype so it can't be in .gvimrc. see :he go
"set guioptions-=m " don't show the menubar, I know all the commands already and want the realestate
set guioptions-=T " don't bother showing the toolbar either
set laststatus=2 " more room for this for (g)vim: always show the status line no matter how many windows are open

syntax on
syntax sync fromstart
" make code indenting smarter and happier
set noautoindent
set nosmartindent
set nocindent
" this works much better than the above three do. adjust as necessary
filetype plugin indent on
set formatoptions=tcrqo

if version >= 600
	set foldenable
	set foldmethod=marker
	set fcl=all "close folds you aren't in, automatically

    colorscheme desert "http://www.vim.org/scripts/script.php?script_id=1143
    "was torte but then I got urxvt! 88-colors in the term! woohoo!
	"kudos to tpope in #vim who mentioned this in conjunction with my wanting
	"88-colors while using vim in screen with urxvt as my terminal
	if $TERM =~ '^screen' && &t_Co == 8 | set t_Co=256 | endif

"choose a sane encoding for terminals
"** unnecessary for vim 7
	if version < 700 
		if has("multi_byte")
			set encoding=utf-8 
			if $TERM == "linux" || $TERM_PROGRAM == "GLterm" 
				set termencoding=latin1 
			endif 
			if $TERM == "xterm" || $TERM == "xterm-color" 
				let propv = system("xprop -id $WINDOWID -f WM_LOCALE_NAME 8s ' $0' -notype WM_LOCALE_NAME") 
				if propv !~ "WM_LOCALE_NAME .*UTF.*8" 
					set termencoding=latin1 
				endif 
			endif 
		endif
	endif
endif
let g:last_pos=0

" default settings for Project plugin
let g:proj_flags='imstbgc'

" attempt to properly diagnose syntax for 'correcter' commenting with EnhancedCommentify
let g:EnhCommentifyUseSyntax = "yes"

" select in visual mode, press * and voila, you're searching for that phrase!
" note that this differs from the normal-mode use of * in that you can phrase-search
vmap * :<C-U>let old_reg=@"<cr>gvy/<C-R><C-R>=substitute(escape(@",'\\/.*$^~[]'),"\\n$","","")<CR><CR>:let @"=old_reg<CR>
imap <C-t> <Esc>
inoremap ;; <Esc>
set paste
filetype plugin on
let $VIMRUNTIME="/Users/majd/.vim/"
let b:delimitMate_expand_cr = "\<CR>\<CR>\<Up>\<Tab>"
