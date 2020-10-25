" ~/.vimrc (configuration file for vim only)
" skeletons
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
set co=110 lines=60	" set width and height of window
set gfn=Liberation\ Mono\ 9
set nu
set ts=3  "tab space
set sw=5  "softswift space
set sta   "smart tab onset vfile=vim.log
" printing settings
set popt=paper:A4
set hls
"backup before overwriting settings
set wb	"write a backup file before overwriting a file
set bex=~ "file name extension for the backup file 
set autochdir "working directory is always the same as the file you are editing.

source $HOME/vimfiles/mswin.vim
source $HOME/vimfiles/templ/headers_tool.vim
source $HOME/vimfiles/templ/statinfo_add_updt.vim
source $HOME/vimfiles/compil_pdflatex.vim
behave mswin

function! SKEL_spec()
	0r /usr/share/vim/current/skeletons/skeleton.spec
	language time en_US
	let login = system('whoami')
	if v:shell_error
	   let login = 'unknown'
	else
	   let newline = stridx(login, "\n")
	   if newline != -1
		let login = strpart(login, 0, newline)
	   endif
	endif
	let hostname = system('hostname -f')
	if v:shell_error
	    let hostname = 'localhost'
	else
	    let newline = stridx(hostname, "\n")
	    if newline != -1
		let hostname = strpart(hostname, 0, newline)
	    endif
	endif
	exe "%s/specRPM_CREATION_DATE/" . strftime("%a\ %b\ %d\ %Y") . "/ge"
	exe "%s/specRPM_CREATION_AUTHOR_MAIL/" . login . "@" . hostname . "/ge"
	exe "%s/specRPM_CREATION_NAME/" . expand("%:t:r") . "/ge"
endfunction
autocmd BufNewFile	*.spec	call SKEL_spec()
" ~/.vimrc ends here
