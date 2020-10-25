"Latex file compile to pdf
function Compilelatex( filename )
     if !exists('a:filename')
		echo "Nezadali jste soubor ke kompilaci!"
		return 1
     endif

     try
		"testovaci prikaz
          let file="\"" . a:filename ."\""

           "Spusti se proces kompilace
	     if isdirectory('/home/michal/workspace/TeXDoc/')
		  let DIR='/home/michal/workspace/TeXDoc/'
	     else
		  let DIR=getcwd()
	     endif

          execute '!pdflatex -output-directory='. DIR . ' ' . file
          return 0
     catch /.*/
	  echo v:exception
	  break
     endtry

endfunction

"Function template insert on cursor position
function InsertFuncTempl(name, cursorln)
	if !exists('a:name')
		let fcename = 'function FunctionNameChange()'
	else
		let fcename = 'function ' . a:name . '()'
	endif

	if !exists('a:cursorln')
	   let cursorln=line('$')
     else
	   let cursorln=a:cursorln
     endif

	try
	   let templ_list = []
	   call add(templ_list, fcename)
	   call add(templ_list, '	if !exists(\"a:args\")')
	   call add(templ_list, '		return 0')
	   call add(templ_list, '	endif')
	   call add(templ_list, '')
	   call add(templ_list, '	try')
	   call add(templ_list, '	')
	   call add(templ_list, '	')
	   call add(templ_list, '	catch /.*/')
	   call add(templ_list, '		echo v:exception')
	   call add(templ_list, '	endtry')
	   call add(templ_list, '')
	   call add(templ_list, 'endfunction')

	   call append(cursorln, templ_list)
	   
     catch /.*/
	   echo 'Exception generate: ' . v:exception
     endtry

endfunction

"Copy .vim file from development directory to main directory
"using only with flash disc where update source file
function CopyFile( filename )
	if !exists('a:filename')
	   echo 'Nutno zadat nazev souboru! Vas vstup '. a:filename
	   return 1
	endif

	let dest_path = "\"C:\\Documents and Settings\\vign54\\Dokumenty\\gVimPortable\\App\\vim\\vimfiles\\""
	try
		echo '!copy /V /Y '. a:filename . ' ' . dest_path
		exe '!copy /V /Y '. a:filename . ' ' . dest_path
		return 0	
	catch /.*/
		echo v:exception
	endtry

endfunction

"TeX file initialize
function TeXFileInit()
	try
		let tex=[]
		call add(tex, '\documentclass[a4paper]{report}')
		call add(tex, '\usepackage[czech]{babel}')
		call add(tex, '\usepackage[utf8]{inputenc}')
		call add(tex, '\usepackage{graphicx}')
		call add(tex, '')
		call add(tex, '%Zde zacina cast pro vlozeni hlavniho textu')
		call add(tex, '\begin{document}')
		call add(tex, '')
		call add(tex, '')
		call add(tex, '\end{document}')
		
		call append(0, tex)
	catch /.*/
		echo v:exception
	endtry

endfunction

"Inserting separate line to end of file
function InsertSepEnd()
	try
		let separ=[]	
		call add(separ, "***************************************************************")
		call add(separ, "")

		call append(line('$'), separ)
		normal G
	catch /.*/
		echo v:exception
	endtry

endfunction

"Inserting separate line on a cursor place
function InsertSep()
	try
		let separ=[]	
		call add(separ, "***************************************************************")
		call add(separ, "")

		call append(line('.'), separ)
		"command line('.') return number of line on the cursor position,
		"line('$') return number of last line in file
		let curpos = line('.') + 1
		normal gg
		"build command (example normal 15j)
		exe "normal " . curpos . "j"
	catch /.*/
		echo v:exception
	endtry

endfunction
