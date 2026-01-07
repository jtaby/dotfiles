" This scheme was created by CSApproxSnapshot
" on Tue, 22 Nov 2011

hi clear
if exists("syntax_on")
    syntax reset
endif

if v:version < 700
    let g:colors_name = expand("<sfile>:t:r")
    command! -nargs=+ CSAHi exe "hi" substitute(substitute(<q-args>, "undercurl", "underline", "g"), "guisp\\S\\+", "", "g")
else
    let g:colors_name = expand("<sfile>:t:r")
    command! -nargs=+ CSAHi exe "hi" <q-args>
endif

function! s:old_kde()
  " Konsole only used its own palette up til KDE 4.2.0
  if executable('kde4-config') && system('kde4-config --kde-version') =~ '^4.[10].'
    return 1
  elseif executable('kde-config') && system('kde-config --version') =~# 'KDE: 3.'
    return 1
  else
    return 0
  endif
endfunction

if 0
elseif has("gui_running") || (&t_Co == 256 && (&term ==# "xterm" || &term =~# "^screen") && exists("g:CSApprox_konsole") && g:CSApprox_konsole) || (&term =~? "^konsole" && s:old_kde())
    CSAHi Normal term=NONE cterm=NONE ctermbg=59 ctermfg=188 gui=NONE guibg=#1e2426 guifg=#babdb6
    CSAHi cssSelectorOp term=NONE cterm=NONE ctermbg=bg ctermfg=255 gui=NONE guibg=bg guifg=#eeeeec
    CSAHi cssUIProp term=NONE cterm=NONE ctermbg=bg ctermfg=188 gui=NONE guibg=bg guifg=#d3d7cf
    CSAHi PreProc term=underline cterm=NONE ctermbg=bg ctermfg=215 gui=NONE guibg=bg guifg=#fcaf3e
    CSAHi Type term=underline cterm=NONE ctermbg=bg ctermfg=194 gui=NONE guibg=bg guifg=#e3e7df
    CSAHi Underlined term=underline cterm=underline ctermbg=bg ctermfg=147 gui=underline guibg=bg guifg=#80a0ff
    CSAHi Ignore term=NONE cterm=NONE ctermbg=bg ctermfg=59 gui=NONE guibg=bg guifg=#1e2426
    CSAHi Error term=reverse cterm=NONE ctermbg=160 ctermfg=255 gui=NONE guibg=#cc0000 guifg=#eeeeec
    CSAHi Todo term=NONE cterm=NONE ctermbg=59 ctermfg=215 gui=NONE guibg=#1e2426 guifg=#fcaf3e
    CSAHi Number term=NONE cterm=NONE ctermbg=bg ctermfg=149 gui=NONE guibg=bg guifg=#8ae234
    CSAHi SpecialKey term=bold cterm=NONE ctermbg=bg ctermfg=203 gui=NONE guibg=bg guifg=#ef2929
    CSAHi NonText term=bold cterm=NONE ctermbg=59 ctermfg=59 gui=NONE guibg=#2c3032 guifg=#2c3032
    CSAHi Directory term=bold cterm=NONE ctermbg=bg ctermfg=231 gui=NONE guibg=bg guifg=#ffffff
    CSAHi ErrorMsg term=NONE cterm=NONE ctermbg=196 ctermfg=231 gui=NONE guibg=#ff0000 guifg=#ffffff
    CSAHi IncSearch term=reverse cterm=reverse ctermbg=215 ctermfg=59 gui=reverse guibg=#2e3436 guifg=#fcaf3e
    CSAHi Search term=reverse cterm=NONE ctermbg=215 ctermfg=59 gui=NONE guibg=#fcaf3e guifg=#2e3436
    CSAHi MoreMsg term=bold cterm=bold ctermbg=bg ctermfg=110 gui=bold guibg=bg guifg=#729fcf
    CSAHi ModeMsg term=bold cterm=bold ctermbg=bg ctermfg=fg gui=bold guibg=bg guifg=fg
    CSAHi LineNr term=underline cterm=NONE ctermbg=16 ctermfg=60 gui=NONE guibg=#000000 guifg=#3f4b4d
    CSAHi htmlTagName term=NONE cterm=NONE ctermbg=bg ctermfg=188 gui=NONE guibg=bg guifg=#babdb6
    CSAHi htmlSpecialTagName term=NONE cterm=NONE ctermbg=bg ctermfg=188 gui=NONE guibg=bg guifg=#babdb6
    CSAHi ICursor term=NONE cterm=NONE ctermbg=188 ctermfg=fg gui=NONE guibg=#babdb6 guifg=fg
    CSAHi phpRegionDelimiter term=NONE cterm=NONE ctermbg=bg ctermfg=139 gui=NONE guibg=bg guifg=#ad7fa8
    CSAHi phpPropertySelector term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpPropertySelectorInString term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpOperator term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpArrayPair term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpAssignByRef term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi SpellLocal term=underline cterm=undercurl ctermbg=bg ctermfg=51 gui=undercurl guibg=bg guifg=fg guisp=#00ffff
    CSAHi Pmenu term=NONE cterm=NONE ctermbg=59 ctermfg=255 gui=NONE guibg=#2e3436 guifg=#eeeeec
    CSAHi PmenuSel term=NONE cterm=NONE ctermbg=231 ctermfg=59 gui=NONE guibg=#ffffff guifg=#1e2426
    CSAHi PmenuSbar term=NONE cterm=NONE ctermbg=102 ctermfg=fg gui=NONE guibg=#555753 guifg=fg
    CSAHi PmenuThumb term=NONE cterm=reverse ctermbg=231 ctermfg=fg gui=reverse guibg=bg guifg=#ffffff
    CSAHi TabLine term=underline cterm=underline ctermbg=16 ctermfg=145 gui=underline guibg=#0a1012 guifg=#888a85
    CSAHi TabLineSel term=bold cterm=NONE ctermbg=102 ctermfg=255 gui=NONE guibg=#555753 guifg=#eeeeec
    CSAHi TabLineFill term=reverse cterm=reverse ctermbg=16 ctermfg=fg gui=reverse guibg=bg guifg=#0a1012
    CSAHi CursorColumn term=reverse cterm=NONE ctermbg=102 ctermfg=fg gui=NONE guibg=#666666 guifg=fg
    CSAHi CursorLine term=underline cterm=NONE ctermbg=102 ctermfg=fg gui=NONE guibg=#666666 guifg=fg
    CSAHi cssPseudoClassId term=NONE cterm=NONE ctermbg=bg ctermfg=255 gui=NONE guibg=bg guifg=#eeeeec
    CSAHi cssBraces term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi cssIdentifier term=NONE cterm=NONE ctermbg=bg ctermfg=215 gui=NONE guibg=bg guifg=#fcaf3e
    CSAHi cssTagName term=NONE cterm=NONE ctermbg=bg ctermfg=215 gui=NONE guibg=bg guifg=#fcaf3e
    CSAHi Function term=NONE cterm=NONE ctermbg=bg ctermfg=215 gui=NONE guibg=bg guifg=#fcaf3e
    CSAHi Keyword term=NONE cterm=NONE ctermbg=bg ctermfg=255 gui=NONE guibg=bg guifg=#eeeeec
    CSAHi Question term=NONE cterm=NONE ctermbg=bg ctermfg=149 gui=NONE guibg=bg guifg=#8ae234
    CSAHi StatusLine term=bold,reverse cterm=NONE ctermbg=188 ctermfg=59 gui=NONE guibg=#babdb6 guifg=#2e3436
    CSAHi StatusLineNC term=reverse cterm=NONE ctermbg=145 ctermfg=59 gui=NONE guibg=#888a85 guifg=#2e3436
    CSAHi VertSplit term=reverse cterm=NONE ctermbg=145 ctermfg=102 gui=NONE guibg=#888a85 guifg=#555753
    CSAHi Title term=bold cterm=bold ctermbg=bg ctermfg=215 gui=bold guibg=bg guifg=#fcaf3e
    CSAHi Visual term=reverse cterm=NONE ctermbg=16 ctermfg=fg gui=NONE guibg=#000000 guifg=fg
    CSAHi VisualNOS term=bold,underline cterm=bold,underline ctermbg=bg ctermfg=fg gui=bold,underline guibg=bg guifg=fg
    CSAHi WarningMsg term=NONE cterm=NONE ctermbg=bg ctermfg=196 gui=NONE guibg=bg guifg=#ff0000
    CSAHi WildMenu term=NONE cterm=NONE ctermbg=233 ctermfg=255 gui=NONE guibg=#0e1416 guifg=#eeeeec
    CSAHi Folded term=NONE cterm=NONE ctermbg=61 ctermfg=188 gui=NONE guibg=#204a87 guifg=#d3d7cf
    CSAHi htmlArg term=NONE cterm=NONE ctermbg=bg ctermfg=188 gui=NONE guibg=bg guifg=#d3d7cf
    CSAHi htmlTitle term=NONE cterm=NONE ctermbg=bg ctermfg=149 gui=NONE guibg=bg guifg=#8ae234
    CSAHi phpVarSelector term=NONE cterm=NONE ctermbg=bg ctermfg=188 gui=NONE guibg=bg guifg=#babdb6
    CSAHi phpSemicolon term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpFunctions term=NONE cterm=NONE ctermbg=bg ctermfg=188 gui=NONE guibg=bg guifg=#d3d7cf
    CSAHi phpParent term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi javaScriptBraces term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi javaScriptOperator term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi htmlTag term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi ColorColumn term=reverse cterm=NONE ctermbg=124 ctermfg=fg gui=NONE guibg=#8b0000 guifg=fg
    CSAHi Cursor term=NONE cterm=NONE ctermbg=188 ctermfg=59 gui=NONE guibg=#babdb6 guifg=#1e2426
    CSAHi lCursor term=NONE cterm=NONE ctermbg=188 ctermfg=59 gui=NONE guibg=#babdb6 guifg=#1e2426
    CSAHi MatchParen term=reverse cterm=NONE ctermbg=215 ctermfg=59 gui=NONE guibg=#fcaf3e guifg=#2e3436
    CSAHi Comment term=bold cterm=NONE ctermbg=bg ctermfg=102 gui=NONE guibg=bg guifg=#656763
    CSAHi Constant term=underline cterm=NONE ctermbg=bg ctermfg=149 gui=NONE guibg=bg guifg=#8ae234
    CSAHi Special term=bold cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi Identifier term=underline cterm=NONE ctermbg=bg ctermfg=231 gui=NONE guibg=bg guifg=#ffffff
    CSAHi Statement term=bold cterm=NONE ctermbg=bg ctermfg=110 gui=NONE guibg=bg guifg=#729fcf
    CSAHi htmlEndTag term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpRelation term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpMemberSelector term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpUnknownSelector term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi FoldColumn term=NONE cterm=NONE ctermbg=16 ctermfg=67 gui=NONE guibg=#000000 guifg=#3465a4
    CSAHi DiffAdd term=bold cterm=NONE ctermbg=59 ctermfg=fg gui=NONE guibg=#1f2b2d guifg=fg
    CSAHi DiffChange term=bold cterm=NONE ctermbg=59 ctermfg=fg gui=NONE guibg=#2e3436 guifg=fg
    CSAHi DiffDelete term=bold cterm=bold ctermbg=233 ctermfg=59 gui=bold guibg=#0e1416 guifg=#2e3436
    CSAHi DiffText term=reverse cterm=NONE ctermbg=16 ctermfg=fg gui=NONE guibg=#000000 guifg=fg
    CSAHi SignColumn term=NONE cterm=NONE ctermbg=59 ctermfg=51 gui=NONE guibg=#1e2426 guifg=#00ffff
    CSAHi Conceal term=NONE cterm=NONE ctermbg=248 ctermfg=252 gui=NONE guibg=#a9a9a9 guifg=#d3d3d3
    CSAHi SpellBad term=reverse cterm=undercurl ctermbg=bg ctermfg=196 gui=undercurl guibg=bg guifg=fg guisp=#ff0000
    CSAHi SpellCap term=reverse cterm=undercurl ctermbg=bg ctermfg=21 gui=undercurl guibg=bg guifg=fg guisp=#0000ff
    CSAHi SpellRare term=reverse cterm=undercurl ctermbg=bg ctermfg=201 gui=undercurl guibg=bg guifg=fg guisp=#ff00ff
elseif has("gui_running") || (&t_Co == 256 && (&term ==# "xterm" || &term =~# "^screen") && exists("g:CSApprox_eterm") && g:CSApprox_eterm) || &term =~? "^eterm"
    CSAHi Normal term=NONE cterm=NONE ctermbg=59 ctermfg=188 gui=NONE guibg=#1e2426 guifg=#babdb6
    CSAHi cssSelectorOp term=NONE cterm=NONE ctermbg=bg ctermfg=255 gui=NONE guibg=bg guifg=#eeeeec
    CSAHi cssUIProp term=NONE cterm=NONE ctermbg=bg ctermfg=231 gui=NONE guibg=bg guifg=#d3d7cf
    CSAHi PreProc term=underline cterm=NONE ctermbg=bg ctermfg=221 gui=NONE guibg=bg guifg=#fcaf3e
    CSAHi Type term=underline cterm=NONE ctermbg=bg ctermfg=231 gui=NONE guibg=bg guifg=#e3e7df
    CSAHi Underlined term=underline cterm=underline ctermbg=bg ctermfg=153 gui=underline guibg=bg guifg=#80a0ff
    CSAHi Ignore term=NONE cterm=NONE ctermbg=bg ctermfg=59 gui=NONE guibg=bg guifg=#1e2426
    CSAHi Error term=reverse cterm=NONE ctermbg=196 ctermfg=255 gui=NONE guibg=#cc0000 guifg=#eeeeec
    CSAHi Todo term=NONE cterm=NONE ctermbg=59 ctermfg=221 gui=NONE guibg=#1e2426 guifg=#fcaf3e
    CSAHi Number term=NONE cterm=NONE ctermbg=bg ctermfg=155 gui=NONE guibg=bg guifg=#8ae234
    CSAHi SpecialKey term=bold cterm=NONE ctermbg=bg ctermfg=203 gui=NONE guibg=bg guifg=#ef2929
    CSAHi NonText term=bold cterm=NONE ctermbg=59 ctermfg=59 gui=NONE guibg=#2c3032 guifg=#2c3032
    CSAHi Directory term=bold cterm=NONE ctermbg=bg ctermfg=255 gui=NONE guibg=bg guifg=#ffffff
    CSAHi ErrorMsg term=NONE cterm=NONE ctermbg=196 ctermfg=255 gui=NONE guibg=#ff0000 guifg=#ffffff
    CSAHi IncSearch term=reverse cterm=reverse ctermbg=221 ctermfg=59 gui=reverse guibg=#2e3436 guifg=#fcaf3e
    CSAHi Search term=reverse cterm=NONE ctermbg=221 ctermfg=59 gui=NONE guibg=#fcaf3e guifg=#2e3436
    CSAHi MoreMsg term=bold cterm=bold ctermbg=bg ctermfg=153 gui=bold guibg=bg guifg=#729fcf
    CSAHi ModeMsg term=bold cterm=bold ctermbg=bg ctermfg=fg gui=bold guibg=bg guifg=fg
    CSAHi LineNr term=underline cterm=NONE ctermbg=16 ctermfg=66 gui=NONE guibg=#000000 guifg=#3f4b4d
    CSAHi htmlTagName term=NONE cterm=NONE ctermbg=bg ctermfg=188 gui=NONE guibg=bg guifg=#babdb6
    CSAHi htmlSpecialTagName term=NONE cterm=NONE ctermbg=bg ctermfg=188 gui=NONE guibg=bg guifg=#babdb6
    CSAHi ICursor term=NONE cterm=NONE ctermbg=188 ctermfg=fg gui=NONE guibg=#babdb6 guifg=fg
    CSAHi phpRegionDelimiter term=NONE cterm=NONE ctermbg=bg ctermfg=182 gui=NONE guibg=bg guifg=#ad7fa8
    CSAHi phpPropertySelector term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpPropertySelectorInString term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpOperator term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpArrayPair term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpAssignByRef term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi SpellLocal term=underline cterm=undercurl ctermbg=bg ctermfg=51 gui=undercurl guibg=bg guifg=fg guisp=#00ffff
    CSAHi Pmenu term=NONE cterm=NONE ctermbg=59 ctermfg=255 gui=NONE guibg=#2e3436 guifg=#eeeeec
    CSAHi PmenuSel term=NONE cterm=NONE ctermbg=255 ctermfg=59 gui=NONE guibg=#ffffff guifg=#1e2426
    CSAHi PmenuSbar term=NONE cterm=NONE ctermbg=102 ctermfg=fg gui=NONE guibg=#555753 guifg=fg
    CSAHi PmenuThumb term=NONE cterm=reverse ctermbg=255 ctermfg=fg gui=reverse guibg=bg guifg=#ffffff
    CSAHi TabLine term=underline cterm=underline ctermbg=16 ctermfg=145 gui=underline guibg=#0a1012 guifg=#888a85
    CSAHi TabLineSel term=bold cterm=NONE ctermbg=102 ctermfg=255 gui=NONE guibg=#555753 guifg=#eeeeec
    CSAHi TabLineFill term=reverse cterm=reverse ctermbg=16 ctermfg=fg gui=reverse guibg=bg guifg=#0a1012
    CSAHi CursorColumn term=reverse cterm=NONE ctermbg=241 ctermfg=fg gui=NONE guibg=#666666 guifg=fg
    CSAHi CursorLine term=underline cterm=NONE ctermbg=241 ctermfg=fg gui=NONE guibg=#666666 guifg=fg
    CSAHi cssPseudoClassId term=NONE cterm=NONE ctermbg=bg ctermfg=255 gui=NONE guibg=bg guifg=#eeeeec
    CSAHi cssBraces term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi cssIdentifier term=NONE cterm=NONE ctermbg=bg ctermfg=221 gui=NONE guibg=bg guifg=#fcaf3e
    CSAHi cssTagName term=NONE cterm=NONE ctermbg=bg ctermfg=221 gui=NONE guibg=bg guifg=#fcaf3e
    CSAHi Function term=NONE cterm=NONE ctermbg=bg ctermfg=221 gui=NONE guibg=bg guifg=#fcaf3e
    CSAHi Keyword term=NONE cterm=NONE ctermbg=bg ctermfg=255 gui=NONE guibg=bg guifg=#eeeeec
    CSAHi Question term=NONE cterm=NONE ctermbg=bg ctermfg=155 gui=NONE guibg=bg guifg=#8ae234
    CSAHi StatusLine term=bold,reverse cterm=NONE ctermbg=188 ctermfg=59 gui=NONE guibg=#babdb6 guifg=#2e3436
    CSAHi StatusLineNC term=reverse cterm=NONE ctermbg=145 ctermfg=59 gui=NONE guibg=#888a85 guifg=#2e3436
    CSAHi VertSplit term=reverse cterm=NONE ctermbg=145 ctermfg=102 gui=NONE guibg=#888a85 guifg=#555753
    CSAHi Title term=bold cterm=bold ctermbg=bg ctermfg=221 gui=bold guibg=bg guifg=#fcaf3e
    CSAHi Visual term=reverse cterm=NONE ctermbg=16 ctermfg=fg gui=NONE guibg=#000000 guifg=fg
    CSAHi VisualNOS term=bold,underline cterm=bold,underline ctermbg=bg ctermfg=fg gui=bold,underline guibg=bg guifg=fg
    CSAHi WarningMsg term=NONE cterm=NONE ctermbg=bg ctermfg=196 gui=NONE guibg=bg guifg=#ff0000
    CSAHi WildMenu term=NONE cterm=NONE ctermbg=233 ctermfg=255 gui=NONE guibg=#0e1416 guifg=#eeeeec
    CSAHi Folded term=NONE cterm=NONE ctermbg=67 ctermfg=231 gui=NONE guibg=#204a87 guifg=#d3d7cf
    CSAHi htmlArg term=NONE cterm=NONE ctermbg=bg ctermfg=231 gui=NONE guibg=bg guifg=#d3d7cf
    CSAHi htmlTitle term=NONE cterm=NONE ctermbg=bg ctermfg=155 gui=NONE guibg=bg guifg=#8ae234
    CSAHi phpVarSelector term=NONE cterm=NONE ctermbg=bg ctermfg=188 gui=NONE guibg=bg guifg=#babdb6
    CSAHi phpSemicolon term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpFunctions term=NONE cterm=NONE ctermbg=bg ctermfg=231 gui=NONE guibg=bg guifg=#d3d7cf
    CSAHi phpParent term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi javaScriptBraces term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi javaScriptOperator term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi htmlTag term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi ColorColumn term=reverse cterm=NONE ctermbg=124 ctermfg=fg gui=NONE guibg=#8b0000 guifg=fg
    CSAHi Cursor term=NONE cterm=NONE ctermbg=188 ctermfg=59 gui=NONE guibg=#babdb6 guifg=#1e2426
    CSAHi lCursor term=NONE cterm=NONE ctermbg=188 ctermfg=59 gui=NONE guibg=#babdb6 guifg=#1e2426
    CSAHi MatchParen term=reverse cterm=NONE ctermbg=221 ctermfg=59 gui=NONE guibg=#fcaf3e guifg=#2e3436
    CSAHi Comment term=bold cterm=NONE ctermbg=bg ctermfg=241 gui=NONE guibg=bg guifg=#656763
    CSAHi Constant term=underline cterm=NONE ctermbg=bg ctermfg=155 gui=NONE guibg=bg guifg=#8ae234
    CSAHi Special term=bold cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi Identifier term=underline cterm=NONE ctermbg=bg ctermfg=255 gui=NONE guibg=bg guifg=#ffffff
    CSAHi Statement term=bold cterm=NONE ctermbg=bg ctermfg=153 gui=NONE guibg=bg guifg=#729fcf
    CSAHi htmlEndTag term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpRelation term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpMemberSelector term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpUnknownSelector term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#888a85
    CSAHi FoldColumn term=NONE cterm=NONE ctermbg=16 ctermfg=68 gui=NONE guibg=#000000 guifg=#3465a4
    CSAHi DiffAdd term=bold cterm=NONE ctermbg=59 ctermfg=fg gui=NONE guibg=#1f2b2d guifg=fg
    CSAHi DiffChange term=bold cterm=NONE ctermbg=59 ctermfg=fg gui=NONE guibg=#2e3436 guifg=fg
    CSAHi DiffDelete term=bold cterm=bold ctermbg=233 ctermfg=59 gui=bold guibg=#0e1416 guifg=#2e3436
    CSAHi DiffText term=reverse cterm=NONE ctermbg=16 ctermfg=fg gui=NONE guibg=#000000 guifg=fg
    CSAHi SignColumn term=NONE cterm=NONE ctermbg=59 ctermfg=51 gui=NONE guibg=#1e2426 guifg=#00ffff
    CSAHi Conceal term=NONE cterm=NONE ctermbg=248 ctermfg=231 gui=NONE guibg=#a9a9a9 guifg=#d3d3d3
    CSAHi SpellBad term=reverse cterm=undercurl ctermbg=bg ctermfg=196 gui=undercurl guibg=bg guifg=fg guisp=#ff0000
    CSAHi SpellCap term=reverse cterm=undercurl ctermbg=bg ctermfg=21 gui=undercurl guibg=bg guifg=fg guisp=#0000ff
    CSAHi SpellRare term=reverse cterm=undercurl ctermbg=bg ctermfg=201 gui=undercurl guibg=bg guifg=fg guisp=#ff00ff
elseif has("gui_running") || &t_Co == 256
    CSAHi Normal term=NONE cterm=NONE ctermbg=16 ctermfg=145 gui=NONE guibg=#1e2426 guifg=#babdb6
    CSAHi cssSelectorOp term=NONE cterm=NONE ctermbg=bg ctermfg=255 gui=NONE guibg=bg guifg=#eeeeec
    CSAHi cssUIProp term=NONE cterm=NONE ctermbg=bg ctermfg=188 gui=NONE guibg=bg guifg=#d3d7cf
    CSAHi PreProc term=underline cterm=NONE ctermbg=bg ctermfg=215 gui=NONE guibg=bg guifg=#fcaf3e
    CSAHi Type term=underline cterm=NONE ctermbg=bg ctermfg=188 gui=NONE guibg=bg guifg=#e3e7df
    CSAHi Underlined term=underline cterm=underline ctermbg=bg ctermfg=111 gui=underline guibg=bg guifg=#80a0ff
    CSAHi Ignore term=NONE cterm=NONE ctermbg=bg ctermfg=16 gui=NONE guibg=bg guifg=#1e2426
    CSAHi Error term=reverse cterm=NONE ctermbg=160 ctermfg=255 gui=NONE guibg=#cc0000 guifg=#eeeeec
    CSAHi Todo term=NONE cterm=NONE ctermbg=16 ctermfg=215 gui=NONE guibg=#1e2426 guifg=#fcaf3e
    CSAHi Number term=NONE cterm=NONE ctermbg=bg ctermfg=113 gui=NONE guibg=bg guifg=#8ae234
    CSAHi SpecialKey term=bold cterm=NONE ctermbg=bg ctermfg=196 gui=NONE guibg=bg guifg=#ef2929
    CSAHi NonText term=bold cterm=NONE ctermbg=236 ctermfg=236 gui=NONE guibg=#2c3032 guifg=#2c3032
    CSAHi Directory term=bold cterm=NONE ctermbg=bg ctermfg=231 gui=NONE guibg=bg guifg=#ffffff
    CSAHi ErrorMsg term=NONE cterm=NONE ctermbg=196 ctermfg=231 gui=NONE guibg=#ff0000 guifg=#ffffff
    CSAHi IncSearch term=reverse cterm=reverse ctermbg=215 ctermfg=23 gui=reverse guibg=#2e3436 guifg=#fcaf3e
    CSAHi Search term=reverse cterm=NONE ctermbg=215 ctermfg=23 gui=NONE guibg=#fcaf3e guifg=#2e3436
    CSAHi MoreMsg term=bold cterm=bold ctermbg=bg ctermfg=74 gui=bold guibg=bg guifg=#729fcf
    CSAHi ModeMsg term=bold cterm=bold ctermbg=bg ctermfg=fg gui=bold guibg=bg guifg=fg
    CSAHi LineNr term=underline cterm=NONE ctermbg=16 ctermfg=59 gui=NONE guibg=#000000 guifg=#3f4b4d
    CSAHi htmlTagName term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#babdb6
    CSAHi htmlSpecialTagName term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#babdb6
    CSAHi ICursor term=NONE cterm=NONE ctermbg=145 ctermfg=fg gui=NONE guibg=#babdb6 guifg=fg
    CSAHi phpRegionDelimiter term=NONE cterm=NONE ctermbg=bg ctermfg=139 gui=NONE guibg=bg guifg=#ad7fa8
    CSAHi phpPropertySelector term=NONE cterm=NONE ctermbg=bg ctermfg=102 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpPropertySelectorInString term=NONE cterm=NONE ctermbg=bg ctermfg=102 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpOperator term=NONE cterm=NONE ctermbg=bg ctermfg=102 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpArrayPair term=NONE cterm=NONE ctermbg=bg ctermfg=102 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpAssignByRef term=NONE cterm=NONE ctermbg=bg ctermfg=102 gui=NONE guibg=bg guifg=#888a85
    CSAHi SpellLocal term=underline cterm=undercurl ctermbg=bg ctermfg=51 gui=undercurl guibg=bg guifg=fg guisp=#00ffff
    CSAHi Pmenu term=NONE cterm=NONE ctermbg=23 ctermfg=255 gui=NONE guibg=#2e3436 guifg=#eeeeec
    CSAHi PmenuSel term=NONE cterm=NONE ctermbg=231 ctermfg=16 gui=NONE guibg=#ffffff guifg=#1e2426
    CSAHi PmenuSbar term=NONE cterm=NONE ctermbg=59 ctermfg=fg gui=NONE guibg=#555753 guifg=fg
    CSAHi PmenuThumb term=NONE cterm=reverse ctermbg=231 ctermfg=fg gui=reverse guibg=bg guifg=#ffffff
    CSAHi TabLine term=underline cterm=underline ctermbg=16 ctermfg=102 gui=underline guibg=#0a1012 guifg=#888a85
    CSAHi TabLineSel term=bold cterm=NONE ctermbg=59 ctermfg=255 gui=NONE guibg=#555753 guifg=#eeeeec
    CSAHi TabLineFill term=reverse cterm=reverse ctermbg=16 ctermfg=fg gui=reverse guibg=bg guifg=#0a1012
    CSAHi CursorColumn term=reverse cterm=NONE ctermbg=241 ctermfg=fg gui=NONE guibg=#666666 guifg=fg
    CSAHi CursorLine term=underline cterm=NONE ctermbg=241 ctermfg=fg gui=NONE guibg=#666666 guifg=fg
    CSAHi cssPseudoClassId term=NONE cterm=NONE ctermbg=bg ctermfg=255 gui=NONE guibg=bg guifg=#eeeeec
    CSAHi cssBraces term=NONE cterm=NONE ctermbg=bg ctermfg=102 gui=NONE guibg=bg guifg=#888a85
    CSAHi cssIdentifier term=NONE cterm=NONE ctermbg=bg ctermfg=215 gui=NONE guibg=bg guifg=#fcaf3e
    CSAHi cssTagName term=NONE cterm=NONE ctermbg=bg ctermfg=215 gui=NONE guibg=bg guifg=#fcaf3e
    CSAHi Function term=NONE cterm=NONE ctermbg=bg ctermfg=215 gui=NONE guibg=bg guifg=#fcaf3e
    CSAHi Keyword term=NONE cterm=NONE ctermbg=bg ctermfg=255 gui=NONE guibg=bg guifg=#eeeeec
    CSAHi Question term=NONE cterm=NONE ctermbg=bg ctermfg=113 gui=NONE guibg=bg guifg=#8ae234
    CSAHi StatusLine term=bold,reverse cterm=NONE ctermbg=145 ctermfg=23 gui=NONE guibg=#babdb6 guifg=#2e3436
    CSAHi StatusLineNC term=reverse cterm=NONE ctermbg=102 ctermfg=23 gui=NONE guibg=#888a85 guifg=#2e3436
    CSAHi VertSplit term=reverse cterm=NONE ctermbg=102 ctermfg=59 gui=NONE guibg=#888a85 guifg=#555753
    CSAHi Title term=bold cterm=bold ctermbg=bg ctermfg=215 gui=bold guibg=bg guifg=#fcaf3e
    CSAHi Visual term=reverse cterm=NONE ctermbg=16 ctermfg=fg gui=NONE guibg=#000000 guifg=fg
    CSAHi VisualNOS term=bold,underline cterm=bold,underline ctermbg=bg ctermfg=fg gui=bold,underline guibg=bg guifg=fg
    CSAHi WarningMsg term=NONE cterm=NONE ctermbg=bg ctermfg=196 gui=NONE guibg=bg guifg=#ff0000
    CSAHi WildMenu term=NONE cterm=NONE ctermbg=233 ctermfg=255 gui=NONE guibg=#0e1416 guifg=#eeeeec
    CSAHi Folded term=NONE cterm=NONE ctermbg=24 ctermfg=188 gui=NONE guibg=#204a87 guifg=#d3d7cf
    CSAHi htmlArg term=NONE cterm=NONE ctermbg=bg ctermfg=188 gui=NONE guibg=bg guifg=#d3d7cf
    CSAHi htmlTitle term=NONE cterm=NONE ctermbg=bg ctermfg=113 gui=NONE guibg=bg guifg=#8ae234
    CSAHi phpVarSelector term=NONE cterm=NONE ctermbg=bg ctermfg=145 gui=NONE guibg=bg guifg=#babdb6
    CSAHi phpSemicolon term=NONE cterm=NONE ctermbg=bg ctermfg=102 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpFunctions term=NONE cterm=NONE ctermbg=bg ctermfg=188 gui=NONE guibg=bg guifg=#d3d7cf
    CSAHi phpParent term=NONE cterm=NONE ctermbg=bg ctermfg=102 gui=NONE guibg=bg guifg=#888a85
    CSAHi javaScriptBraces term=NONE cterm=NONE ctermbg=bg ctermfg=102 gui=NONE guibg=bg guifg=#888a85
    CSAHi javaScriptOperator term=NONE cterm=NONE ctermbg=bg ctermfg=102 gui=NONE guibg=bg guifg=#888a85
    CSAHi htmlTag term=NONE cterm=NONE ctermbg=bg ctermfg=102 gui=NONE guibg=bg guifg=#888a85
    CSAHi ColorColumn term=reverse cterm=NONE ctermbg=88 ctermfg=fg gui=NONE guibg=#8b0000 guifg=fg
    CSAHi Cursor term=NONE cterm=NONE ctermbg=145 ctermfg=16 gui=NONE guibg=#babdb6 guifg=#1e2426
    CSAHi lCursor term=NONE cterm=NONE ctermbg=145 ctermfg=16 gui=NONE guibg=#babdb6 guifg=#1e2426
    CSAHi MatchParen term=reverse cterm=NONE ctermbg=215 ctermfg=23 gui=NONE guibg=#fcaf3e guifg=#2e3436
    CSAHi Comment term=bold cterm=NONE ctermbg=bg ctermfg=241 gui=NONE guibg=bg guifg=#656763
    CSAHi Constant term=underline cterm=NONE ctermbg=bg ctermfg=113 gui=NONE guibg=bg guifg=#8ae234
    CSAHi Special term=bold cterm=NONE ctermbg=bg ctermfg=102 gui=NONE guibg=bg guifg=#888a85
    CSAHi Identifier term=underline cterm=NONE ctermbg=bg ctermfg=231 gui=NONE guibg=bg guifg=#ffffff
    CSAHi Statement term=bold cterm=NONE ctermbg=bg ctermfg=74 gui=NONE guibg=bg guifg=#729fcf
    CSAHi htmlEndTag term=NONE cterm=NONE ctermbg=bg ctermfg=102 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpRelation term=NONE cterm=NONE ctermbg=bg ctermfg=102 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpMemberSelector term=NONE cterm=NONE ctermbg=bg ctermfg=102 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpUnknownSelector term=NONE cterm=NONE ctermbg=bg ctermfg=102 gui=NONE guibg=bg guifg=#888a85
    CSAHi FoldColumn term=NONE cterm=NONE ctermbg=16 ctermfg=61 gui=NONE guibg=#000000 guifg=#3465a4
    CSAHi DiffAdd term=bold cterm=NONE ctermbg=16 ctermfg=fg gui=NONE guibg=#1f2b2d guifg=fg
    CSAHi DiffChange term=bold cterm=NONE ctermbg=23 ctermfg=fg gui=NONE guibg=#2e3436 guifg=fg
    CSAHi DiffDelete term=bold cterm=bold ctermbg=233 ctermfg=23 gui=bold guibg=#0e1416 guifg=#2e3436
    CSAHi DiffText term=reverse cterm=NONE ctermbg=16 ctermfg=fg gui=NONE guibg=#000000 guifg=fg
    CSAHi SignColumn term=NONE cterm=NONE ctermbg=16 ctermfg=51 gui=NONE guibg=#1e2426 guifg=#00ffff
    CSAHi Conceal term=NONE cterm=NONE ctermbg=248 ctermfg=252 gui=NONE guibg=#a9a9a9 guifg=#d3d3d3
    CSAHi SpellBad term=reverse cterm=undercurl ctermbg=bg ctermfg=196 gui=undercurl guibg=bg guifg=fg guisp=#ff0000
    CSAHi SpellCap term=reverse cterm=undercurl ctermbg=bg ctermfg=21 gui=undercurl guibg=bg guifg=fg guisp=#0000ff
    CSAHi SpellRare term=reverse cterm=undercurl ctermbg=bg ctermfg=201 gui=undercurl guibg=bg guifg=fg guisp=#ff00ff
elseif has("gui_running") || &t_Co == 88
    CSAHi Normal term=NONE cterm=NONE ctermbg=80 ctermfg=85 gui=NONE guibg=#1e2426 guifg=#babdb6
    CSAHi cssSelectorOp term=NONE cterm=NONE ctermbg=bg ctermfg=87 gui=NONE guibg=bg guifg=#eeeeec
    CSAHi cssUIProp term=NONE cterm=NONE ctermbg=bg ctermfg=86 gui=NONE guibg=bg guifg=#d3d7cf
    CSAHi PreProc term=underline cterm=NONE ctermbg=bg ctermfg=72 gui=NONE guibg=bg guifg=#fcaf3e
    CSAHi Type term=underline cterm=NONE ctermbg=bg ctermfg=87 gui=NONE guibg=bg guifg=#e3e7df
    CSAHi Underlined term=underline cterm=underline ctermbg=bg ctermfg=39 gui=underline guibg=bg guifg=#80a0ff
    CSAHi Ignore term=NONE cterm=NONE ctermbg=bg ctermfg=80 gui=NONE guibg=bg guifg=#1e2426
    CSAHi Error term=reverse cterm=NONE ctermbg=48 ctermfg=87 gui=NONE guibg=#cc0000 guifg=#eeeeec
    CSAHi Todo term=NONE cterm=NONE ctermbg=80 ctermfg=72 gui=NONE guibg=#1e2426 guifg=#fcaf3e
    CSAHi Number term=NONE cterm=NONE ctermbg=bg ctermfg=40 gui=NONE guibg=bg guifg=#8ae234
    CSAHi SpecialKey term=bold cterm=NONE ctermbg=bg ctermfg=64 gui=NONE guibg=bg guifg=#ef2929
    CSAHi NonText term=bold cterm=NONE ctermbg=80 ctermfg=80 gui=NONE guibg=#2c3032 guifg=#2c3032
    CSAHi Directory term=bold cterm=NONE ctermbg=bg ctermfg=79 gui=NONE guibg=bg guifg=#ffffff
    CSAHi ErrorMsg term=NONE cterm=NONE ctermbg=64 ctermfg=79 gui=NONE guibg=#ff0000 guifg=#ffffff
    CSAHi IncSearch term=reverse cterm=reverse ctermbg=72 ctermfg=80 gui=reverse guibg=#2e3436 guifg=#fcaf3e
    CSAHi Search term=reverse cterm=NONE ctermbg=72 ctermfg=80 gui=NONE guibg=#fcaf3e guifg=#2e3436
    CSAHi MoreMsg term=bold cterm=bold ctermbg=bg ctermfg=38 gui=bold guibg=bg guifg=#729fcf
    CSAHi ModeMsg term=bold cterm=bold ctermbg=bg ctermfg=fg gui=bold guibg=bg guifg=fg
    CSAHi LineNr term=underline cterm=NONE ctermbg=16 ctermfg=21 gui=NONE guibg=#000000 guifg=#3f4b4d
    CSAHi htmlTagName term=NONE cterm=NONE ctermbg=bg ctermfg=85 gui=NONE guibg=bg guifg=#babdb6
    CSAHi htmlSpecialTagName term=NONE cterm=NONE ctermbg=bg ctermfg=85 gui=NONE guibg=bg guifg=#babdb6
    CSAHi ICursor term=NONE cterm=NONE ctermbg=85 ctermfg=fg gui=NONE guibg=#babdb6 guifg=fg
    CSAHi phpRegionDelimiter term=NONE cterm=NONE ctermbg=bg ctermfg=53 gui=NONE guibg=bg guifg=#ad7fa8
    CSAHi phpPropertySelector term=NONE cterm=NONE ctermbg=bg ctermfg=83 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpPropertySelectorInString term=NONE cterm=NONE ctermbg=bg ctermfg=83 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpOperator term=NONE cterm=NONE ctermbg=bg ctermfg=83 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpArrayPair term=NONE cterm=NONE ctermbg=bg ctermfg=83 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpAssignByRef term=NONE cterm=NONE ctermbg=bg ctermfg=83 gui=NONE guibg=bg guifg=#888a85
    CSAHi SpellLocal term=underline cterm=undercurl ctermbg=bg ctermfg=31 gui=undercurl guibg=bg guifg=fg guisp=#00ffff
    CSAHi Pmenu term=NONE cterm=NONE ctermbg=80 ctermfg=87 gui=NONE guibg=#2e3436 guifg=#eeeeec
    CSAHi PmenuSel term=NONE cterm=NONE ctermbg=79 ctermfg=80 gui=NONE guibg=#ffffff guifg=#1e2426
    CSAHi PmenuSbar term=NONE cterm=NONE ctermbg=81 ctermfg=fg gui=NONE guibg=#555753 guifg=fg
    CSAHi PmenuThumb term=NONE cterm=reverse ctermbg=79 ctermfg=fg gui=reverse guibg=bg guifg=#ffffff
    CSAHi TabLine term=underline cterm=underline ctermbg=16 ctermfg=83 gui=underline guibg=#0a1012 guifg=#888a85
    CSAHi TabLineSel term=bold cterm=NONE ctermbg=81 ctermfg=87 gui=NONE guibg=#555753 guifg=#eeeeec
    CSAHi TabLineFill term=reverse cterm=reverse ctermbg=16 ctermfg=fg gui=reverse guibg=bg guifg=#0a1012
    CSAHi CursorColumn term=reverse cterm=NONE ctermbg=81 ctermfg=fg gui=NONE guibg=#666666 guifg=fg
    CSAHi CursorLine term=underline cterm=NONE ctermbg=81 ctermfg=fg gui=NONE guibg=#666666 guifg=fg
    CSAHi cssPseudoClassId term=NONE cterm=NONE ctermbg=bg ctermfg=87 gui=NONE guibg=bg guifg=#eeeeec
    CSAHi cssBraces term=NONE cterm=NONE ctermbg=bg ctermfg=83 gui=NONE guibg=bg guifg=#888a85
    CSAHi cssIdentifier term=NONE cterm=NONE ctermbg=bg ctermfg=72 gui=NONE guibg=bg guifg=#fcaf3e
    CSAHi cssTagName term=NONE cterm=NONE ctermbg=bg ctermfg=72 gui=NONE guibg=bg guifg=#fcaf3e
    CSAHi Function term=NONE cterm=NONE ctermbg=bg ctermfg=72 gui=NONE guibg=bg guifg=#fcaf3e
    CSAHi Keyword term=NONE cterm=NONE ctermbg=bg ctermfg=87 gui=NONE guibg=bg guifg=#eeeeec
    CSAHi Question term=NONE cterm=NONE ctermbg=bg ctermfg=40 gui=NONE guibg=bg guifg=#8ae234
    CSAHi StatusLine term=bold,reverse cterm=NONE ctermbg=85 ctermfg=80 gui=NONE guibg=#babdb6 guifg=#2e3436
    CSAHi StatusLineNC term=reverse cterm=NONE ctermbg=83 ctermfg=80 gui=NONE guibg=#888a85 guifg=#2e3436
    CSAHi VertSplit term=reverse cterm=NONE ctermbg=83 ctermfg=81 gui=NONE guibg=#888a85 guifg=#555753
    CSAHi Title term=bold cterm=bold ctermbg=bg ctermfg=72 gui=bold guibg=bg guifg=#fcaf3e
    CSAHi Visual term=reverse cterm=NONE ctermbg=16 ctermfg=fg gui=NONE guibg=#000000 guifg=fg
    CSAHi VisualNOS term=bold,underline cterm=bold,underline ctermbg=bg ctermfg=fg gui=bold,underline guibg=bg guifg=fg
    CSAHi WarningMsg term=NONE cterm=NONE ctermbg=bg ctermfg=64 gui=NONE guibg=bg guifg=#ff0000
    CSAHi WildMenu term=NONE cterm=NONE ctermbg=16 ctermfg=87 gui=NONE guibg=#0e1416 guifg=#eeeeec
    CSAHi Folded term=NONE cterm=NONE ctermbg=21 ctermfg=86 gui=NONE guibg=#204a87 guifg=#d3d7cf
    CSAHi htmlArg term=NONE cterm=NONE ctermbg=bg ctermfg=86 gui=NONE guibg=bg guifg=#d3d7cf
    CSAHi htmlTitle term=NONE cterm=NONE ctermbg=bg ctermfg=40 gui=NONE guibg=bg guifg=#8ae234
    CSAHi phpVarSelector term=NONE cterm=NONE ctermbg=bg ctermfg=85 gui=NONE guibg=bg guifg=#babdb6
    CSAHi phpSemicolon term=NONE cterm=NONE ctermbg=bg ctermfg=83 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpFunctions term=NONE cterm=NONE ctermbg=bg ctermfg=86 gui=NONE guibg=bg guifg=#d3d7cf
    CSAHi phpParent term=NONE cterm=NONE ctermbg=bg ctermfg=83 gui=NONE guibg=bg guifg=#888a85
    CSAHi javaScriptBraces term=NONE cterm=NONE ctermbg=bg ctermfg=83 gui=NONE guibg=bg guifg=#888a85
    CSAHi javaScriptOperator term=NONE cterm=NONE ctermbg=bg ctermfg=83 gui=NONE guibg=bg guifg=#888a85
    CSAHi htmlTag term=NONE cterm=NONE ctermbg=bg ctermfg=83 gui=NONE guibg=bg guifg=#888a85
    CSAHi ColorColumn term=reverse cterm=NONE ctermbg=32 ctermfg=fg gui=NONE guibg=#8b0000 guifg=fg
    CSAHi Cursor term=NONE cterm=NONE ctermbg=85 ctermfg=80 gui=NONE guibg=#babdb6 guifg=#1e2426
    CSAHi lCursor term=NONE cterm=NONE ctermbg=85 ctermfg=80 gui=NONE guibg=#babdb6 guifg=#1e2426
    CSAHi MatchParen term=reverse cterm=NONE ctermbg=72 ctermfg=80 gui=NONE guibg=#fcaf3e guifg=#2e3436
    CSAHi Comment term=bold cterm=NONE ctermbg=bg ctermfg=81 gui=NONE guibg=bg guifg=#656763
    CSAHi Constant term=underline cterm=NONE ctermbg=bg ctermfg=40 gui=NONE guibg=bg guifg=#8ae234
    CSAHi Special term=bold cterm=NONE ctermbg=bg ctermfg=83 gui=NONE guibg=bg guifg=#888a85
    CSAHi Identifier term=underline cterm=NONE ctermbg=bg ctermfg=79 gui=NONE guibg=bg guifg=#ffffff
    CSAHi Statement term=bold cterm=NONE ctermbg=bg ctermfg=38 gui=NONE guibg=bg guifg=#729fcf
    CSAHi htmlEndTag term=NONE cterm=NONE ctermbg=bg ctermfg=83 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpRelation term=NONE cterm=NONE ctermbg=bg ctermfg=83 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpMemberSelector term=NONE cterm=NONE ctermbg=bg ctermfg=83 gui=NONE guibg=bg guifg=#888a85
    CSAHi phpUnknownSelector term=NONE cterm=NONE ctermbg=bg ctermfg=83 gui=NONE guibg=bg guifg=#888a85
    CSAHi FoldColumn term=NONE cterm=NONE ctermbg=16 ctermfg=21 gui=NONE guibg=#000000 guifg=#3465a4
    CSAHi DiffAdd term=bold cterm=NONE ctermbg=80 ctermfg=fg gui=NONE guibg=#1f2b2d guifg=fg
    CSAHi DiffChange term=bold cterm=NONE ctermbg=80 ctermfg=fg gui=NONE guibg=#2e3436 guifg=fg
    CSAHi DiffDelete term=bold cterm=bold ctermbg=16 ctermfg=80 gui=bold guibg=#0e1416 guifg=#2e3436
    CSAHi DiffText term=reverse cterm=NONE ctermbg=16 ctermfg=fg gui=NONE guibg=#000000 guifg=fg
    CSAHi SignColumn term=NONE cterm=NONE ctermbg=80 ctermfg=31 gui=NONE guibg=#1e2426 guifg=#00ffff
    CSAHi Conceal term=NONE cterm=NONE ctermbg=84 ctermfg=86 gui=NONE guibg=#a9a9a9 guifg=#d3d3d3
    CSAHi SpellBad term=reverse cterm=undercurl ctermbg=bg ctermfg=64 gui=undercurl guibg=bg guifg=fg guisp=#ff0000
    CSAHi SpellCap term=reverse cterm=undercurl ctermbg=bg ctermfg=19 gui=undercurl guibg=bg guifg=fg guisp=#0000ff
    CSAHi SpellRare term=reverse cterm=undercurl ctermbg=bg ctermfg=67 gui=undercurl guibg=bg guifg=fg guisp=#ff00ff
endif

if 1
    delcommand CSAHi
endif
