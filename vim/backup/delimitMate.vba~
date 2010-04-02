" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
doc/delimitMate.txt	[[[1
440
*delimitMate.txt* Trying to keep those beasts at bay! v.1.6


                              REFERENCE MANUAL *delimitMate*


==============================================================================
 0.- CONTENTS                                           *delimitMate-contents*

    1. Introduction____________________________|delimitMateIntro|
    2. Functionality___________________________|delimitMateFunctionality|
        2.1 Automatic closing & exiting________|delimitMateAutoClose|
        2.2 Expansion of space and CR__________|delimitMateExpansion|
        2.3 Deletion of empty pairs____________|delimitMateBackspace|
        2.4 Visual wrapping____________________|delimitMateVisualWrapping|
    3. Customization___________________________|delimitMateOptions|
        3.1 Option summary_____________________|delimitMateOptionSummary|
        3.2 Options details____________________|delimitMateOptionDetails|
    4. Commands________________________________|delimitMateCommands|
    5. TODO list_______________________________|delimitMateTodo|
    6. Maintainer______________________________|delimitMateMaintainer|
    7. Credits_________________________________|delimitMateCredits|
    8. History_________________________________|delimitMateHistory|

==============================================================================
 1.- INTRODUCTION                                           *delimitMateIntro*

The delimitMate plugin tries to provide some not so dumb help in the work with
delimiters (brackets, quotes, etc.), with some optional auto-completions and
expansions.

When automatic closing is enabled, if an opening delimiter is inserted
delimitMate inserts the closing pair and places the cursor between them. When
automatic closing is disabled, no closing delimiters is inserted by
delimitMate, but if a pair of delimiters is typed, the cursor is placed in the
middle. Also, to get out of a pair of delimiters just type the right delimiter
and the cursor will jump to the right.

If the cursor is inside an empty pair of delimiters <Space> and <CR> can be
expanded to follow your coding style, you just need to define a couple of
options with the desired mappings for them.

==============================================================================
 2. FUNCTIONALITY                                   *delimitMateFunctionality*

------------------------------------------------------------------------------
   2.1 AUTOMATIC CLOSING AND EXITING                    *delimitMateAutoClose*

With automatic closing enabled, if an opening delimiter is inserted the plugin
inserts the closing delimiter and places the cursor between the pair. With
automatic closing disabled, no closing delimiters is inserted by delimitMate,
but when a pair of delimiters is typed, the cursor is placed in the middle.

When the cursor is inside an empty pair or located next to the left of a
closing delimiter, the cursor is placed outside the pair to the right of the
closing delimiter.

Unless |'b:delimitMate_matchpairs'| and |'b:delimitMate_quotes'|is set, this
script uses the values in '&matchpairs' to identify the pairs, and ", ' and `
for quotes respectively.

The following table shows the behaviour, this applies to quotes too (the final
position of the cursor is represented by a "|"):

With auto-close: >
                          Type   |  You get
                        ====================
                           (     |    (|)
                        –––––––––|––––––––––
                           ()    |    ()|
<
Without auto-close: >

                          Type   |  You get
                        ====================
                           ()    |    (|)
                        –––––––––|––––––––––
                           ())   |    ()|
<
------------------------------------------------------------------------------
   2.2 EXPANSION OF SPACE AND CAR RETURN                *delimitMateExpansion*

When the cursor is inside an empty pair of delimiters, <Space> and <CR> can be
expanded to follow your coding style with |'b:delimitMate_expand_space'| and
|'b:delimitMate_expand_cr'|. e.g. (cursor represented by a "|"):

Expand <Space> to: >

                  <Space><Space><Left>  |  You get
                ====================================
                            (|)         |    ( | )
<
Expand <CR> to: >

                    <CR><CR><Up>  |  You get
                  ============================
                         (|)      |    (
                                  |    |
                                  |    )
<

------------------------------------------------------------------------------
   2.3 DELETION OF EMPTY PAIR                           *delimitMateBackspace*

If you press backspace inside an empty pair, both delimiters are deleted.

e.g.: >

                 Before           |  After
               ====================================
                 call expand(|)   |  call expand|
<

------------------------------------------------------------------------------
   2.4 WRAPPING OF VISUAL SELECTION                *delimitMateVisualWrapping*

When visual mode is active this script allows for the selection to be enclosed
with delimiters. But, since brackets have special meaning in visual mode, a
leader (the value of 'mapleader' by default) should precede the delimiter.
This feature doesn't currently work on blockwise visual mode, any suggestions
will be welcome.

e.g. (selection represented between square brackets): >

             Selected text       |  After \"
           =============================================
            An [absurd] example! | An "absurd" example!
<
==============================================================================
 3. CUSTOMIZATION                                         *delimitMateOptions*

------------------------------------------------------------------------------
   3.1 OPTIONS SUMMARY                              *delimitMateOptionSummary*

The behaviour of this script can be customized setting the following options
in your vimrc file. You can use local options to set the configuration for
specific file types, see |delimitMateOptionDetails| for examples.

|'loaded_delimitMate'|          Turns off the script.

|'delimitMate_autoclose'|       Tells delimitMate whether to automagically
                                insert the closing delimiter.

|'delimitMate_matchpairs'|      Tells delimitMate which characters are
                                matching pairs.

|'delimitMate_quotes'|          Tells delimitMate which quotes should be
                                used.

|'delimitMate_visual_leader'|   Sets the leader to be used in visual mode.

|'delimitMate_expand_cr'|       Sets the expansion for <CR> inside an empty
                                pair of matching delimiters or quotes.

|'delimitMate_expand_space'|    Sets the expansion for <Space> inside an
                                empty pair of matching delimiters or quotes.

|'delimitMate_excluded_ft'|     Turns off the script for the given file types.

|'delimitMate_apostrophes'|     Tells delimitMate how it should "fix"
                                balancing of single quotes when used as
                                apostrophes.

------------------------------------------------------------------------------
   3.2 OPTIONS DETAILS                              *delimitMateOptionDetails*

Add the shown lines to your vimrc file in order to set the below options.
Local options take precedence over global ones and can be used along with
autocmd to modify delimitMate's behavior for specific file types.

                                                     *'loaded_delimitMate'*
                                                   *'b:loaded_delimitMate'*
This option prevents delimitMate from loading.
e.g.: >
        let loaded_delimitMate = 1
        au FileType mail let b:loaded_delimitMate = 1
<
------------------------------------------------------------------------------
                                                     *'delimitMate_autoclose'*
                                                   *'b:delimitMate_autoclose'*
Values: 0 or 1.                                                              ~
Default: 1                                                                   ~

If this option is set to 0, delimitMate will not add a closing delimiter
automagically. See |delimitMateAutoClose| for details.
e.g.: >
        let delimitMate_autoclose = 0
        au FileType mail let b:delimitMate_autoclose = 0
<
------------------------------------------------------------------------------
                                                    *'delimitMate_matchpairs'*
                                                  *'b:delimitMate_matchpairs'*
Values: A string with |matchpairs| syntax.                                   ~
Default: &matchpairs                                                         ~

Use this option to tell delimitMate which characters should be considered
matching pairs. Read |delimitMateAutoClose| for details.
e.g: >
        let delimitMate = "(:),[:],{:},<:>"
        au FileType vim,html let b:delimitMate_matchpairs = "(:),[:],{:},<:>"
<
------------------------------------------------------------------------------
                                                        *'delimitMate_quotes'*
                                                      *'b:delimitMate_quotes'*
Values: A string of characters separated by spaces.                          ~
Default: "\" ' `"                                                            ~

Use this option to tell delimitMate which characters should be considered as
quotes. Read |delimitMateAutoClose| for details.
e.g.: >
        let b:delimitMate_quotes = "\" ' ` *"
        au FileType html let b:delimitMate_quotes = "\" '"
<
------------------------------------------------------------------------------
                                                 *'delimitMate_visual_leader'*
                                               *'b:delimitMate_visual_leader'*
Values: Any character.                                                       ~
Default: q                                                                   ~

The value of this option will be used to wrap the selection in visual mode
when followed by a delimiter. Read |delimitMateVisualWrap| for details.
e.g: >
        let delimitMate_visual_leader = "f"
        au FileType html let b:delimitMate_visual_leader = "f"
<
------------------------------------------------------------------------------
                                                     *'delimitMate_expand_cr'*
                                                   *'b:delimitMate_expand_cr'*
Values: A key mapping.                                                       ~
Default: "\<CR>"                                                             ~

The value of this option will be used to expand the car return character when
typed inside an empty delimiter pair. Read |delimitMateExpansion| for details.
e.g.: >
        let b:delimitMate_expand_cr = "\<CR>\<CR>\<Up>"
        au FileType mail let b:delimitMate_expand_cr = "\<CR>
<
------------------------------------------------------------------------------
                                                  *'delimitMate_expand_space'*
                                                *'b:delimitMate_expand_space'*
Values: A key mapping.                                                       ~
Default: "\<Space>"                                                          ~

The value of this option will be used to expand the space character when typed
inside an empty delimiter pair. Read |delimitMateExpansion| for details.
e.g.: >
        let delimitMate_expand_space = "\<Space>\<Space>\<Left>"
        au FileType tcl let b:delimitMate_expand_space = "\<Space>"
<
------------------------------------------------------------------------------
                                                   *'delimitMate_excluded_ft'*
Values: A string of file type names separated by single commas.              ~
Default: Empty.                                                              ~

This options turns delimitMate off for the listed file types, use this option
only if don't want any of the features it provides.
e.g.: >
        let delimitMate_excluded_ft = "mail,txt"
<
------------------------------------------------------------------------------
                                                   *'delimitMate_apostrophes'*
Values: Strings separated by ":".                                            ~
Default: "n't:'s:'re:'d:'ll:'ve:s'"                                          ~

If auto-close is enabled, this option tells delimitMate how to try to fix the
balancing of single quotes when used as apostrophes. The values of this option
are strings of text where a single quote would be used as an apostrophe (e.g.:
the "n't" of wouldn't or can't) separated by ":". Set it to an empty string to
disable this feature.
e.g.: >
        let delimitMate_apostrophes = ""
        au FileType tcl let delimitMate_apostrophes = ""
<
==============================================================================
 4. COMMANDS                                             *delimitMateCommands*

------------------------------------------------------------------------------
:DelimitMateReload                                        *:DelimitMateReload*

Re-sets all the mappings used for this script, use it if any option has been
changed or if the filetype option hasn't been set yet.

------------------------------------------------------------------------------
:DelimitMateTest                                            *:DelimitMateTest*

This command tests every mapping set-up for this script, useful for testing
custom configurations.

The following output corresponds to the default values, it will be different
depending on your configuration. "Open & close:" represents the final result
when the closing delimiter has been inserted, either manually or
automatically, see |delimitMateExpansion|. "Delete:" typing backspace in an
empty pair, see |delimitMateBackspace|. "Exit:" typing a closing delimiter
inside a pair of delimiters, see |delimitMateAutoclose|. "Space:" the
expansion, if any, of space, see |delimitMateExpansion|. "Visual-L",
"Visual-R" and "Visual" shows visual wrapping, see
|delimitMateVisualWrapping|. "Car return:" the expansion of car return, see
|delimitMateExpansion|. The cursor's position at the end of every test is
represented by an "|": >

            * AUTOCLOSE:
            Open & close: (|)
            Delete: |
            Exit: ()|
            Space: ( |)
            Visual-L: (v)
            Visual-R: (v)
            Car return: (
            |)

            Open & close: {|}
            Delete: |
            Exit: {}|
            Space: { |}
            Visual-L: {v}
            Visual-R: {v}
            Car return: {
            |}

            Open & close: [|]
            Delete: |
            Exit: []|
            Space: [ |]
            Visual-L: [v]
            Visual-R: [v]
            Car return: [
            |]

            Open & close: "|"
            Delete: |
            Exit: ""|
            Space: " |"
            Visual: "v"
            Car return: "
            |"

            Open & close: '|'
            Delete: |
            Exit: ''|
            Space: ' |'
            Visual: 'v'
            Car return: '
            |'

            Open & close: `|`
            Delete: |
            Exit: ``|
            Space: ` |`
            Visual: `v`
            Car return: `
            |`
<

==============================================================================
 5. TODO LIST                                                *delimitMateTodo*

- Automatic set-up by file type.
- Make visual wrapping work on blockwise visual mode.
- Limit behaviour by region.

==============================================================================
 6. MAINTAINER                                         *delimitMateMaintainer*

Hi there! My name is Israel Chauca F. and I can be reached at:
    mailto:israelchauca@gmail.com

Feel free to send me any suggestions and/or comments about this plugin, I'll
be very pleased to read them.

==============================================================================
 7. CREDITS                                               *delimitMateCredits*

Some of the code that make this script is modified or just shamelessly copied
from the following sources:

   - Ian McCracken
     Post titled: Vim, Part II: Matching Pairs:
     http://concisionandconcinnity.blogspot.com/

   - Aristotle Pagaltzis
     From the comments on the previous blog post and from:
     http://gist.github.com/144619

   - Vim Scripts:
     http://www.vim.org/scripts

This script was inspired by the auto-completion of delimiters of TextMate.

==============================================================================
 8. HISTORY                                               *delimitMateHistory*

  Version      Date      Release notes                                       ~
|---------|------------|-----------------------------------------------------|
    1.6     2009-10-10   Now delimitMate tries to fix the balancing of single
                         quotes when used as apostrophes. You can read
                         |delimitMate_apostrophes| for details.
                         Fixed an error when |b:delimitMate_expand_space|
                         wasn't set but |delimitMate_expand_space| wasn't.

|---------|------------|-----------------------------------------------------|
    1.5     2009-10-05   Fix: delimitMate should work correctly for files
                         passed as arguments to Vim. Thanks to Ben Beuchler
                         for helping to nail this bug.

|---------|------------|-----------------------------------------------------|
    1.4     2009-09-27   Fix: delimitMate is now enabled on new buffers even
                         if they don't have set the file type option or were
                         opened directly from the terminal.

|---------|------------|-----------------------------------------------------|
    1.3     2009-09-24   Now local options can be used along with autocmd
                         for specific file type configurations.
                         Fixes:
                         - Unnamed register content is not lost on visual
                         mode.
                         - Use noremap where appropiate.
                         - Wrapping a single empty line works as expected.

|---------|------------|-----------------------------------------------------|
    1.2	    2009-09-07   Fixes:
                         - When inside nested empty pairs, deleting the
                         innermost left delimiter would delete all right
                         contiguous delimiters.
                         - When inside an empty pair, inserting a left
                         delimiter wouldn't insert the right one, instead
                         the cursor would jump to the right.
                         - New buffer inside the current window wouldn't
                         have the mappings set.

|---------|------------|-----------------------------------------------------|
    1.1     2009-08-25   Fixed an error that ocurred when mapleader wasn't
                         set and added support for GetLatestScripts
                         auto-detection.

|---------|------------|-----------------------------------------------------|
    1.0     2009-08-23   Initial upload.

|---------|------------|-----------------------------------------------------|

vim:tw=78:ts=8:ft=help:norl:formatoptions+=tcroqn:autoindent:
plugin/delimitMate.vim	[[[1
547
" ============================================================================
" File:        delimitMate.vim
" Version:     1.6
" Description: This plugin tries to emulate the auto-completion of delimiters
"              that TextMate provides.
" Maintainer:  Israel Chauca F. <israelchauca@gmail.com>
" Manual:      Read ":help delimitMate".
" Credits:     Some of the code is modified or just copied from the following:
"
"              - Ian McCracken
"           	 Post titled: Vim, Part II: Matching Pairs:
"           	 http://concisionandconcinnity.blogspot.com/
"
"              - Aristotle Pagaltzis
"           	 From the comments on the previous blog post and from:
"           	 http://gist.github.com/144619
"
"              - Vim Scripts:
"           	 http://www.vim.org/scripts/

if exists("g:loaded_delimitMate") "{{{1
	" User doesn't want this plugin, let's get out!
	finish
endif
let g:loaded_delimitMate = 1

if exists("s:loaded_delimitMate") && !exists("g:delimitMate_testing")
	" Don't define the functions if they already exist: just do the work
	" (unless we are testing):
	call s:DelimitMateDo()
	finish
endif

if v:version < 700
	echoerr "delimitMate: this plugin requires vim >= 7!"
	finish
endif

let s:loaded_delimitMate = 1 " }}}1

function! s:Init() "{{{1

	if !exists("b:delimitMate_autoclose") && !exists("g:delimitMate_autoclose") " {{{
		let s:autoclose = 1
	elseif exists("b:delimitMate_autoclose")
		let s:autoclose = b:delimitMate_autoclose
	else
		let s:autoclose = g:delimitMate_autoclose
	endif " }}}

	if !exists("b:delimitMate_matchpairs") && !exists("g:delimitMate_matchpairs") " {{{
		if s:ValidMatchpairs(&matchpairs) == 1
			let s:matchpairs_temp = &matchpairs
		else
			echoerr "delimitMate: There seems to be a problem with 'matchpairs', read ':help matchpairs' and fix it or notify the maintainer of this script if this is a bug."
			finish
		endif
	elseif exists("b:delimitMate_matchpairs")
		if s:ValidMatchpairs(b:delimitMate_matchpairs) || b:delimitMate_matchpairs == ""
			let s:matchpairs_temp = b:delimitMate_matchpairs
		else
			echoerr "delimitMate: Invalid format in 'b:delimitMate_matchpairs', falling back to matchpairs. Fix the error and use the command :DelimitMateReload to try again."
			if s:ValidMatchpairs(&matchpairs) == 1
				let s:matchpairs_temp = &matchpairs
			else
				echoerr "delimitMate: There seems to be a problem with 'matchpairs', read ':help matchpairs' and fix it or notify the maintainer of this script if this is a bug."
				let s:matchpairs_temp = ""
			endif
		endif
	else
		if s:ValidMatchpairs(g:delimitMate_matchpairs) || g:delimitMate_matchpairs == ""
			let s:matchpairs_temp = g:delimitMate_matchpairs
		else
			echoerr "delimitMate: Invalid format in 'g:delimitMate_matchpairs', falling back to matchpairs. Fix the error and use the command :DelimitMateReload to try again."
			if s:ValidMatchpairs(&matchpairs) == 1
				let s:matchpairs_temp = &matchpairs
			else
				echoerr "delimitMate: There seems to be a problem with 'matchpairs', read ':help matchpairs' and fix it or notify the maintainer of this script if this is a bug."
				let s:matchpairs_temp = ""
			endif
		endif

	endif " }}}

	if exists("b:delimitMate_quotes") " {{{
		if b:delimitMate_quotes =~ '^\(\S\)\(\s\S\)*$' || b:delimitMate_quotes == ""
			let s:quotes = split(b:delimitMate_quotes)
		else
			let s:quotes = split("\" ' `")
			echoerr "delimitMate: There is a problem with the format of 'b:delimitMate_quotes', it should be a string of single characters separated by spaces. Falling back to default values."
		endif
	elseif exists("g:delimitMate_quotes")
		if g:delimitMate_quotes =~ '^\(\S\)\(\s\S\)*$' || g:delimitMate_quotes == ""
			let s:quotes = split(g:delimitMate_quotes)
		else
			let s:quotes = split("\" ' `")
			echoerr "delimitMate: There is a problem with the format of 'g:delimitMate_quotes', it should be a string of single characters separated by spaces. Falling back to default values."
		endif
	else
		let s:quotes = split("\" ' `")
	endif " }}}

	if !exists("b:delimitMate_visual_leader") && !exists("g:delimitMate_visual_leader") " {{{
		if !exists("g:mapleader")
			let s:visual_leader = "\\"
		else
			let s:visual_leader = g:mapleader
		endif
	elseif exists("b:delimitMate_visual_leader")
		let s:visual_leader = b:delimitMate_visual_leader
	else
		let s:visual_leader = g:delimitMate_visual_leader
	endif " }}}

	if !exists("b:delimitMate_expand_space") && !exists("g:delimitMate_expand_space") " {{{
		let s:expand_space = "\<Space>"
	elseif exists("b:delimitMate_expand_space")
		if b:delimitMate_expand_space == ""
			let s:expand_space = "\<Space>"
		else
			let s:expand_space = b:delimitMate_expand_space
		endif
	else
		if g:delimitMate_expand_space == ""
			let s:expand_space = "\<Space>"
		else
			let s:expand_space = g:delimitMate_expand_space
		endif

	endif " }}}

	if !exists("b:delimitMate_expand_cr") && !exists("g:delimitMate_expand_cr") " {{{
		let s:expand_return = "\<CR>"
	elseif exists("b:delimitMate_expand_cr")
		if b:delimitMate_expand_cr == ""
			let s:expand_return = "\<CR>"
		else
			let s:expand_return = b:delimitMate_expand_cr
		endif
	else
		if g:delimitMate_expand_cr == ""
			let s:expand_return = "\<CR>"
		else
			let s:expand_return = g:delimitMate_expand_cr
		endif

	endif " }}}

	if !exists("b:delimitMate_apostrophes") && !exists("g:delimitMate_apostrophes") " {{{
		let s:apostrophes = split("n't:'s:'re:'m:'d:'ll:'ve:s'",':')

	elseif exists("b:delimitMate_apostrophes")
		let s:apostrophes = split(b:delimitMate_apostrophes)
	else
		let s:apostrophes = split(g:delimitMate_apostrophes)
	endif " }}}

	let s:matchpairs = split(s:matchpairs_temp, ',')
	let s:left_delims = split(s:matchpairs_temp, ':.,\=')
	let s:right_delims = split(s:matchpairs_temp, ',\=.:')
	let s:VMapMsg = "delimitMate: delimitMate is disabled on blockwise visual mode."

	call s:UnMap()
	if s:autoclose
		call s:AutoClose()
	else
		call s:NoAutoClose()
	endif
	call s:VisualMaps()
	call s:ExtraMappings()
	let b:loaded_delimitMate = 1

endfunction "}}}1

function! s:ValidMatchpairs(str) "{{{1
	if a:str !~ '^.:.\(,.:.\)*$'
		return 0
	endif
	for pair in split(a:str,',')
		if strpart(pair, 0, 1) == strpart(pair, 2, 1) || strlen(pair) != 3
			return 0
		endif
	endfor
	return 1
endfunction "}}}1

function! s:IsEmptyPair(str) "{{{1
	for pair in s:matchpairs
		if a:str == join( split( pair, ':' ),'' )
			return 1
		endif
	endfor
	for quote in s:quotes
		if a:str == quote . quote
			return 1
		endif
	endfor
	return 0
endfunction "}}}1

function! s:WithinEmptyPair() "{{{1
	let cur = strpart( getline('.'), col('.')-2, 2 )
	return s:IsEmptyPair( cur )
endfunction "}}}1

function! s:SkipDelim(char) "{{{1
	let cur = strpart( getline('.'), col('.')-2, 3 )
	if cur[0] == "\\"
		" Escaped character
		return a:char
	elseif cur[1] == a:char
		" Exit pair
		return "\<Right>"
	elseif cur[1] == ' ' && cur[2] == a:char
		" I'm leaving this in case someone likes it. Jump an space and delimiter.
		return "\<Right>\<Right>"
	elseif s:IsEmptyPair( cur[0] . a:char )
		" Add closing delimiter and jump back to the middle.
		return a:char . "\<Left>"
	else
		" Nothing special here, return the same character.
		return a:char
	endif
endfunction "}}}1

function! s:QuoteDelim(char) "{{{1
	let line = getline('.')
	let col = col('.')
	if line[col - 2] == "\\"
		" Seems like a escaped character, insert a single quotation mark.
		return a:char
	elseif line[col - 1] == a:char
		" Get out of the string.
		return "\<Right>"
	else
		" Insert a pair and jump to the middle.
		return a:char.a:char."\<Left>"
	endif
endfunction "}}}1

function! s:ClosePair(char) "{{{1
	if getline('.')[col('.') - 1] == a:char
		" Same character on the rigth, jump it.
		return "\<Right>"
	else
		" Insert character.
		return a:char
	endif
endfunction "}}}1

function! s:ResetMappings() "{{{1
	for delim in s:right_delims + s:left_delims + s:quotes
		silent! exec 'iunmap <buffer> ' . delim
		silent! exec 'vunmap <buffer> ' . s:visual_leader . delim
	endfor
	silent! iunmap <buffer> <CR>
	silent! iunmap <buffer> <Space>
endfunction "}}}1

function! s:MapMsg(msg) "{{{1
	redraw
	echomsg a:msg
	return ""
endfunction "}}}1

function! s:NoAutoClose() "{{{1
	" inoremap <buffer> ) <C-R>=<SID>SkipDelim('\)')<CR>
	for delim in s:right_delims + s:quotes
		exec 'inoremap <buffer> ' . delim . ' <C-R>=<SID>SkipDelim("' . escape(delim,'"') . '")<CR>'
	endfor
endfunction "}}}1

function! s:AutoClose() "{{{1
	" Add matching pair and jump to the midle:
	" inoremap <buffer> ( ()<Left>
	let s:i = 0
	while s:i < len(s:matchpairs)
		exec 'inoremap <buffer> ' . s:left_delims[s:i] . ' ' . s:left_delims[s:i] . s:right_delims[s:i] . '<Left>'
		let s:i += 1
	endwhile

	" Add matching quote and jump to the midle, or exit if inside a pair of matching quotes:
	" inoremap <buffer> " <C-R>=<SID>QuoteDelim("\"")<CR>
	for delim in s:quotes
		exec 'inoremap <buffer> ' . delim . ' <C-R>=<SID>QuoteDelim("\' . delim . '")<CR>'
	endfor

	" Exit from inside the matching pair:
	" inoremap <buffer> ) <C-R>=<SID>ClosePair(')')<CR>
	for delim in s:right_delims
		exec 'inoremap <buffer> ' . delim . ' <C-R>=<SID>ClosePair("\' . delim . '")<CR>'
	endfor

	" Try to fix the use of apostrophes:
	" inoremap <buffer> n't n't
	for map in s:apostrophes
		exec "inoremap <buffer> " . map . " " . map
	endfor

endfunction "}}}1

function! s:VisualMaps() " {{{1
	" Wrap the selection with matching pairs, but do nothing if blockwise visual mode is active:
	let s:i = 0
	while s:i < len(s:matchpairs)
		" Map left delimiter:
		" vnoremap <buffer> <expr> \( <SID>IsBlockVisual() ? <SID>MapMsg("Message") : "s(\<C-R>\")\<Esc>:call <SID>RestoreRegister()<CR>"
		exec 'vnoremap <buffer> <expr> ' . s:visual_leader . s:left_delims[s:i] . ' <SID>IsBlockVisual() ? <SID>MapMsg("' . s:VMapMsg . '") : "s' . s:left_delims[s:i] . '\<C-R>\"' . s:right_delims[s:i] . '\<Esc>:call <SID>RestoreRegister()<CR>"'

		" Map right delimiter:
		" vnoremap <buffer> <expr> \) <SID>IsBlockVisual() ? <SID>MapMsg("Message") : "s(\<C-R>\")\<Esc>:call <SID>RestoreRegister()<CR>"
		exec 'vnoremap <buffer> <expr> ' . s:visual_leader . s:right_delims[s:i] . ' <SID>IsBlockVisual() ? <SID>MapMsg("' . s:VMapMsg . '") : "s' . s:left_delims[s:i] . '\<C-R>\"' . s:right_delims[s:i] . '\<Esc>:call <SID>RestoreRegister()<CR>"'
		let s:i += 1
	endwhile

	" Wrap the selection with matching quotes, but do nothing if blockwise visual mode is active:
	for quote in s:quotes
		" vnoremap <buffer> <expr> \' <SID>IsBlockVisual() ? <SID>MapMsg("Message") : "s'\<C-R>\"'\<Esc>:call <SID>RestoreRegister()<CR>"
		exec 'vnoremap <buffer> <expr> ' . s:visual_leader . quote . ' <SID>IsBlockVisual() ? <SID>MapMsg("' . s:VMapMsg . '") : "s' . escape(quote,'"') .'\<C-R>\"' . escape(quote,'"') . '\<Esc>:call <SID>RestoreRegister()<CR>"'
	endfor
endfunction "}}}1

function! s:IsBlockVisual() " {{{1
	if visualmode() == "<C-V>"
		return 1
	endif
	" Store unnamed register values for later use in s:RestoreRegister().
	let s:save_reg = getreg('"')
	let s:save_reg_mode = getregtype('"')

	if len(getline('.')) == 0
		" This for proper wrap of empty lines.
		let @" = "\n"
	endif
	return 0
endfunction " }}}1

function! s:RestoreRegister() " {{{1
	" Restore unnamed register values store in s:IsBlockVisual().
	call setreg('"', s:save_reg, s:save_reg_mode)
	echo ""
endfunction " }}}1

function! s:ExpandReturn() "{{{1
	if s:WithinEmptyPair()
		" Expand:
		return s:expand_return
	else
		" Don't
		return "\<CR>"
	endif
endfunction "}}}1

function! s:ExpandSpace() "{{{1
	if s:WithinEmptyPair()
		" Expand:
		return s:expand_space
	else
		" Don't
		return "\<Space>"
	endif
endfunction "}}}1

function! s:ExtraMappings() "{{{1
	" If pair is empty, delete both delimiters:
	inoremap <buffer> <expr> <BS> <SID>WithinEmptyPair() ? "\<Right>\<BS>\<BS>" : "\<BS>"

	" Expand return if inside an empty pair:
	if exists("b:delimitMate_expand_cr") || exists("g:delimitMate_expand_cr")
		inoremap <buffer> <CR> <C-R>=<SID>ExpandReturn()<CR>
	endif

	" Expand space if inside an empty pair:
	if exists("b:delimitMate_expand_space") || exists("g:delimitMate_expand_space")
		inoremap <buffer> <Space> <C-R>=<SID>ExpandSpace()<CR>
	endif
endfunction "}}}1

function! s:TestMappings() "{{{1
	if s:autoclose
		 exec "normal i* AUTOCLOSE:\<CR>"
		for i in range(len(s:left_delims))
			exec "normal GGAOpen & close: " . s:left_delims[i]. "|"
			exec "normal A\<CR>Delete: " . s:left_delims[i] . "\<BS>|"
			exec "normal A\<CR>Exit: " . s:left_delims[i] . s:right_delims[i] . "|"
			exec "normal A\<CR>Space: " . s:left_delims[i] . " |"
			exec "normal GGA\<CR>Visual-L: v\<Esc>v" . s:visual_leader . s:left_delims[i]
			exec "normal A\<CR>Visual-R: v\<Esc>v" . s:visual_leader . s:right_delims[i]
			exec "normal A\<CR>Car return: " . s:left_delims[i] . "\<CR>|\<Esc>GGA\<CR>\<CR>"
		endfor
		for i in range(len(s:quotes))
			exec "normal GGAOpen & close: " . s:quotes[i]	. "|"
			exec "normal A\<CR>Delete: " . s:quotes[i] . "\<BS>|"
			exec "normal A\<CR>Exit: " . s:quotes[i] . s:quotes[i] . "|"
			exec "normal A\<CR>Space: " . s:quotes[i] . " |"
			exec "normal GGA\<CR>Visual: v\<Esc>v" . s:visual_leader . s:quotes[i]
			exec "normal A\<CR>Car return: " . s:quotes[i] . "\<CR>|\<Esc>GGA\<CR>\<CR>"
		endfor
	else
		exec "normal i* NO AUTOCLOSE:\<CR>"
		for i in range(len(s:left_delims))
			exec "normal GGAOpen & close: " . s:left_delims[i]	. s:right_delims[i] . "|"
			exec "normal A\<CR>Delete: " . s:left_delims[i] . s:right_delims[i] . "\<BS>|"
			exec "normal A\<CR>Exit: " . s:left_delims[i] . s:right_delims[i] . s:right_delims[i] . "|"
			exec "normal A\<CR>Space: " . s:left_delims[i] . s:right_delims[i] . " |"
			exec "normal GGA\<CR>Visual-L: v\<Esc>v" . s:visual_leader . s:left_delims[i]
			exec "normal A\<CR>Visual-R: v\<Esc>v" . s:visual_leader . s:right_delims[i]
			exec "normal A\<CR>Car return: " . s:left_delims[i] . s:right_delims[i] . "\<CR>|\<Esc>GGA\<CR>\<CR>"
		endfor
		for i in range(len(s:quotes))
			exec "normal GGAOpen & close: " . s:quotes[i]	. s:quotes[i] . "|"
			exec "normal A\<CR>Delete: " . s:quotes[i] . s:quotes[i] . "\<BS>|"
			exec "normal A\<CR>Exit: " . s:quotes[i] . s:quotes[i] . s:quotes[i] . "|"
			exec "normal A\<CR>Space: " . s:quotes[i] . s:quotes[i] . " |"
			exec "normal GGA\<CR>Visual: v\<Esc>v" . s:visual_leader . s:quotes[i]
			exec "normal A\<CR>Car return: " . s:quotes[i] . s:quotes[i] . "\<CR>|\<Esc>GGA\<CR>\<CR>"
		endfor
	endif
	exec "normal \<Esc>i"
endfunction "}}}1

function! s:SwitchAutoclose() "{{{1
	if !exists("g:delimitMate_autoclose")
		let g:delimitMate_autoclose = 1
	elseif g:delimitMate_autoclose == 1
		let g:delimitMate_autoclose = 0
	else
		let g:delimitMate_autoclose = 1
	endif
	DelimitMateReload
endfunction "}}}1

function! s:UnMap() " {{{
	" No Autoclose Mappings:
	for char in s:right_delims + s:quotes
		if maparg(char,"i") =~? 'SkipDelim'
			exec 'iunmap <buffer> ' . char
			"echomsg 'iunmap <buffer> ' . char
		endif
	endfor

	" Autoclose Mappings:
	let s:i = 0
	while s:i < len(s:matchpairs)
		if maparg(s:left_delims[s:i],"i") =~? s:left_delims[s:i] . s:right_delims[s:i] . '<Left>'
			exec 'iunmap <buffer> ' . s:left_delims[s:i]
			"echomsg 'iunmap <buffer> ' . s:left_delims[s:i]
		endif
		let s:i += 1
	endwhile
	for char in s:quotes
		if maparg(char, "i") =~? 'QuoteDelim'
			exec 'iunmap <buffer> ' . char
			"echomsg 'iunmap <buffer> ' . char
		endif
	endfor
	for char in s:right_delims
		if maparg(char, "i") =~? 'ClosePair'
			exec 'iunmap <buffer> ' . char
			"echomsg 'iunmap <buffer> ' . char
		endif
	endfor
	for map in s:apostrophes
		exec "silent! iunmap <buffer> " . map
	endfor

	" Visual Mappings:
	for char in s:right_delims + s:left_delims + s:quotes
		if maparg(s:visual_leader . char,"v") =~? 'IsBlock'
			exec 'vunmap <buffer> ' . s:visual_leader . char
			"echomsg 'vunmap <buffer> ' . s:visual_leader . char
		endif
	endfor

	" Expansion Mappings:
	if maparg('<BS>', "i") =~? 'WithinEmptyPair'
		iunmap <buffer> <BS>
		"echomsg "iunmap <buffer> <BS>"
	endif
	if maparg('<CR>',"i") =~? 'ExpandReturn'
		iunmap <buffer> <CR>
		"echomsg "iunmap <buffer> <CR>"
	endif
	if maparg('<Space>',"i") =~? 'ExpandSpace'
		iunmap <buffer> <Space>
		"echomsg "iunmap <buffer> <Space>"
	endif

endfunction " }}}

function! s:TestMappingsDo() "{{{1
	if !exists("g:delimitMate_testing")
		call s:DelimitMateDo()
		call s:TestMappings()
	else
		call s:SwitchAutoclose()
		call s:TestMappings()
		exec "normal i\<CR>"
		call s:SwitchAutoclose()
		call s:TestMappings()
	endif
endfunction "}}}1

function! s:DelimitMateDo() "{{{1
	if exists("g:delimitMate_excluded_ft")
		" Check if this file type is excluded:
		for ft in split(g:delimitMate_excluded_ft,',')
			if ft ==? &filetype
				if !exists("s:quotes")
					return 1
				endif
				"echomsg "excluded"
				call s:UnMap()
				return 1
			endif
		endfor
	endif
	try
		"echomsg "included"
		let save_cpo = &cpo
		set cpo&vim
		call s:Init()
	finally
		let &cpo = save_cpo
	endtry
endfunction "}}}1

" Set some commands: {{{1
call s:DelimitMateDo()

" Let me refresh without re-loading the buffer:
command! DelimitMateReload call s:DelimitMateDo()

" Quick test:
command! DelimitMateTest call s:TestMappingsDo()

" Run on file type events.
"autocmd VimEnter * autocmd FileType * call <SID>DelimitMateDo()
autocmd FileType * call <SID>DelimitMateDo()

" Run on new buffers.
autocmd BufNewFile,BufRead,BufEnter * if !exists("b:loaded_delimitMate") | call <SID>DelimitMateDo() | endif

"function! s:GetSynRegion () | echo synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name') | endfunction

" GetLatestVimScripts: 2754 1 :AutoInstall: delimitMate.vim
" vim:foldmethod=marker:foldcolumn=2
