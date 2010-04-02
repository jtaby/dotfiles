" Vim syntax support file
" Maintainer:	Bram Moolenaar <mool@oce.nl>
" Last change:	1997 July 12

" This is the startup file for syntax highlighting.
" It sets the default highlighting methods, and installs autocommands for all
" the available syntax files.

if has("syntax")

  " The default methods for highlighting.  Can be overridden later.
  " There should be only six of these, because many terminals can only use
  " six different colors (plus black and white).  It doesn't look nice with
  " too many colors too.
  " Careful with "cterm=bold", on rxvt it changes the color to bright.
  highlight Comment	term=bold ctermfg=Blue guifg=Blue
  highlight Constant	term=bold ctermfg=red guifg=red gui=bold
  highlight Identifier	term=bold ctermfg=DarkCyan guifg=DarkCyan
  highlight Statement	term=bold ctermfg=Brown gui=bold guifg=Brown
  highlight PreProc	term=bold ctermfg=Magenta guifg=Purple
  highlight Type	term=bold ctermfg=DarkGreen guifg=SeaGreen gui=bold
  highlight Special	term=bold ctermfg=DarkBlue guifg=SlateBlue gui=underline

  " These two change the background
  highlight Error	term=reverse ctermbg=Red guibg=Orange
  highlight Todo	term=standout cterm=bold ctermbg=Yellow guifg=Blue guibg=Yellow

  " Common groups that link to default highlighting.
  " You can specify other highlighting easily.
  highlight link String		Constant
  highlight link Character	Constant
  highlight link Number		Constant
  highlight link Boolean	Constant
  highlight link Float		Number
  highlight link Function	Identifier
  highlight link Conditional	Statement
  highlight link Repeat		Statement
  highlight link Label		Statement
  highlight link Operator	Statement
  highlight link Keyword	Statement
  highlight link Include	PreProc
  highlight link Define		PreProc
  highlight link Macro		PreProc
  highlight link PreCondit	PreProc
  highlight link StorageClass	Type
  highlight link Structure	Type
  highlight link Typedef	Type
  highlight link Tag		Special

  augroup highlight

  " Ada (83, 9X, 95)
  au BufNewFile,BufReadPost *.adb,*.ads		so $VIM/syntax/ada.vim

  " Assembly (GNU)
  au BufNewFile,BufReadPost *.asm,*.s		so $VIM/syntax/asm.vim

  " Awk
  au BufNewFile,BufReadPost *.awk		so $VIM/syntax/awk.vim

  " Batch file for MSDOS
  au BufNewFile,BufReadPost *.bat,*.sys		so $VIM/syntax/dosbatch.vim

  " C
  au BufNewFile,BufReadPost *.c			so $VIM/syntax/c.vim

  " C++
  au BufNewFile,BufReadPost *.cpp,*.cc,*.h,*.cxx,*.c++,*.C,*.H,*.hh so $VIM/syntax/cpp.vim

  " Century Term Command Scripts
  au BufNewFile,BufReadPost *.cmd,*.con		so $VIM/syntax/cterm.vim

  " Diff files
  au BufNewFile,BufReadPost *.diff		so $VIM/syntax/diff.vim

  " Fortran
  au BufNewFile,BufReadPost *.f,*.for,*.fpp	so $VIM/syntax/fortran.vim

 " Fortran90
  au BufNewFile,BufReadPost *.f90        	so $VIM/syntax/fortran90.vim

  " HTML
  au BufNewFile,BufReadPost *.html,*.htm	so $VIM/syntax/html.vim

  " Java
  au BufNewFile,BufReadPost *.java		so $VIM/syntax/java.vim

  " JavaCC
  au BufNewFile,BufReadPost *.jj		so $VIM/syntax/javacc.vim

  " Lex
  au BufNewFile,BufReadPost *.lex,*.l		so $VIM/syntax/lex.vim

  " Lisp
  au BufNewFile,BufReadPost *.lsp,*.L		so $VIM/syntax/lisp.vim

  " Mail (for Elm, trn and rn)
  au BufNewFile,BufReadPost snd.*,.letter,.article,.article.[0-9]\+,pico.[0-9]\+,mutt[0-9]\+ so $VIM/syntax/mail.vim

  " Makefile
  au BufNewFile,BufReadPost [mM]akefile*	so $VIM/syntax/make.vim

  " Maple V
  au BufNewFile,BufReadPost *.mv		so $VIM/syntax/maple.vim

  " Matlab
  au BufNewFile,BufReadPost *.m			so $VIM/syntax/matlab.vim

  " Pascal
  au BufNewFile,BufReadPost *.p,*.pas		so $VIM/syntax/pascal.vim

  " Perl
  au BufNewFile,BufReadPost *.pl,*.pm		so $VIM/syntax/perl.vim

  " PostScript
  au BufNewFile,BufReadPost *.ps,*.eps		so $VIM/syntax/postscr.vim

  " Prolog
  au BufNewFile,BufReadPost *.pdb		so $VIM/syntax/prolog.vim

  " Python
  au BufNewFile,BufReadPost *.py		so $VIM/syntax/python.vim

  " Sather
  au BufNewFile,BufReadPost *.sa		so $VIM/syntax/sather.vim

  " Shell scripts (sh, ksh, bash, csh)
  au BufNewFile,BufReadPost .profile,.bashrc	so $VIM/syntax/sh.vim
  au BufNewFile,BufReadPost .login,.cshrc	so $VIM/syntax/csh.vim

  " Z-Shell script
  au BufNewFile,BufReadPost .z*,zsh*,zlog*	so $VIM/syntax/zsh.vim

  " SQL
  au BufNewFile,BufReadPost *.sql		so $VIM/syntax/sql.vim

  " TeX
  au BufNewFile,BufReadPost *.tex,*.sty		so $VIM/syntax/tex.vim

  " Motif UIT/UIL files
  au BufNewFile,BufReadPost *.uit,*.uil         so $VIM/syntax/uil.vim

  " Verilog HDL
  au BufNewFile,BufReadPost *.v			so $VIM/syntax/verilog.vim

  " Tcl
  au BufNewFile,BufReadPost *.tcl		so $VIM/syntax/tcl.vim

  " VHDL
  au BufNewFile,BufReadPost *.hdl,*.vhd,*.vhdl,*.vhdl_[0-9]*,*.vbe,*.vst  so $VIM/syntax/vhdl.vim
 
  " Vim Help file
  au BufNewFile,BufReadPost */vim*/doc/*.txt	so $VIM/syntax/help.vim

  " Vim script
  au BufNewFile,BufReadPost *.*vimrc,*.vim,.exrc,_*vimrc,_exrc so $VIM/syntax/vim.vim

  " VRML V1.0c
  au BufNewFile,BufReadPost *.wrl		so $VIM/syntax/vrml.vim

  " Xmath
  au BufNewFile,BufReadPost *.ms,*.msc,*.msf	so $VIM/syntax/xmath.vim

  " Yacc
  au BufNewFile,BufReadPost *.y			so $VIM/syntax/yacc.vim

  " Various scripts, without a specific extension
  au BufNewFile,BufReadPost *			so $VIM/syntax/scripts.vim

  augroup END

  if has("gui")
    50nmenu Syntax.off			:syn clear<CR>
    50nmenu Syntax.ABCDE.Ada		:so $VIM/syntax/ada.vim<CR>
    50nmenu Syntax.ABCDE.assembly	:so $VIM/syntax/asm.vim<CR>
    50nmenu Syntax.ABCDE.Awk		:so $VIM/syntax/awk.vim<CR>
    50nmenu Syntax.ABCDE.C		:so $VIM/syntax/c.vim<CR>
    50nmenu Syntax.ABCDE.C++		:so $VIM/syntax/cpp.vim<CR>
    50nmenu Syntax.ABCDE.Century\ Term	:so $VIM/syntax/cterm.vim<CR>
    50nmenu Syntax.ABCDE.Csh\ shell\ script :so $VIM/syntax/csh.vim<CR>
    50nmenu Syntax.ABCDE.Diff		:so $VIM/syntax/diff.vim<CR>
    50nmenu Syntax.FGHIJ.Fortran	:so $VIM/syntax/fortran.vim<CR>
    50nmenu Syntax.FGHIJ.HTML		:so $VIM/syntax/html.vim<CR>
    50nmenu Syntax.FGHIJ.Java		:so $VIM/syntax/java.vim<CR>
    50nmenu Syntax.FGHIJ.JavaCC		:so $VIM/syntax/javacc.vim<CR>
    50nmenu Syntax.KLMNO.Lex		:so $VIM/syntax/lex.vim<CR>
    50nmenu Syntax.KLMNO.Lisp		:so $VIM/syntax/lisp.vim<CR>
    50nmenu Syntax.KLMNO.Mail		:so $VIM/syntax/mail.vim<CR>
    50nmenu Syntax.KLMNO.Makefile	:so $VIM/syntax/make.vim<CR>
    50nmenu Syntax.KLMNO.Maple		:so $VIM/syntax/maple.vim<CR>
    50nmenu Syntax.KLMNO.Matlab		:so $VIM/syntax/matlab.vim<CR>
    50nmenu Syntax.KLMNO.MS-DOS\ \.bat\ file :so $VIM/syntax/dosbatch.vim<CR>
    50nmenu Syntax.KLMNO.Objective\ C	:so $VIM/syntax/objc.vim<CR>
    50nmenu Syntax.PQRST.Pascal		:so $VIM/syntax/pascal.vim<CR>
    50nmenu Syntax.PQRST.Perl		:so $VIM/syntax/perl.vim<CR>
    50nmenu Syntax.PQRST.PostScript	:so $VIM/syntax/postscr.vim<CR>
    50nmenu Syntax.PQRST.Prolog		:so $VIM/syntax/prolog.vim<CR>
    50nmenu Syntax.PQRST.Python		:so $VIM/syntax/python.vim<CR>
    50nmenu Syntax.PQRST.Sather		:so $VIM/syntax/sather.vim<CR>
    50nmenu Syntax.PQRST.Sh\ shell\ script :so $VIM/syntax/sh.vim<CR>
    50nmenu Syntax.PQRST.SQL		:so $VIM/syntax/sql.vim<CR>
    50nmenu Syntax.PQRST.Tex		:so $VIM/syntax/tex.vim<CR>
    50nmenu Syntax.PQRST.Tcl		:so $VIM/syntax/tcl.vim<CR>
    50nmenu Syntax.UVWXYZ.UIT/UIL	:so $VIM/syntax/uil.vim<CR>
    50nmenu Syntax.UVWXYZ.Verilog\ HDL	:so $VIM/syntax/verilog.vim<CR>
    50nmenu Syntax.UVWXYZ.VHDL		:so $VIM/syntax/vhdl.vim<CR>
    50nmenu Syntax.UVWXYZ.Vim\ help\ file :so $VIM/syntax/help.vim<CR>
    50nmenu Syntax.UVWXYZ.Vim\ script	:so $VIM/syntax/vim.vim<CR>
    50nmenu Syntax.UVWXYZ.VRML		:so $VIM/syntax/vrml.vim<CR>
    50nmenu Syntax.UVWXYZ.Xmath		:so $VIM/syntax/xmath.vim<CR>
    50nmenu Syntax.UVWXYZ.Yacc		:so $VIM/syntax/yacc.vim<CR>
    50nmenu Syntax.UVWXYZ.Zsh\ shell\ script :so $VIM/syntax/zsh.vim<CR>
  endif

  " Execute the highlight autocommands for the each buffer.
  doautoall highlight BufReadPost

endif

