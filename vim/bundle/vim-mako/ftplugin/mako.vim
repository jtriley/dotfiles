" Mako filetype plugin file
" Language:	mako
" Maintainer:	Justin Riley <justin.t.riley@gmail.com>
" Last Change:	Mon, 11 Apr 2011 13:13:08 EST

if exists("b:did_ftplugin") | finish | endif
let b:did_ftplugin = 1

setlocal suffixesadd=.mako
setlocal comments-=:%
setlocal commentstring=##%s

if has("gui_win32") && !exists("b:browsefilter")
    let b:browsefilter = "Mako Files (*.mako)\t*.mako\n" .
		       \ "All Files (*.*)\t*.*\n"
endif

autocmd BufNewFile,BufRead *.mako setlocal ft=mako
