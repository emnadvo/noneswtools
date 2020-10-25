"Insert GNU header on head of file
function InsertGNULicence()
	let header=[]
	call add(header, "Copyright (C) <year>")
	call add(header, "")
	call add(header, "This program is free software; you can redistribute it and/or modify")
	call add(header, "it under the terms of the GNU General Public License as published by")
	call add(header, "the Free Software Foundation; either version 2 of the License, or")
	call add(header, "(at your option) any later version.")
	call add(header, "")
	call add(header, "This program is distributed in the hope that it will be useful,")
	call add(header, "but WITHOUT ANY WARRANTY; without even the implied warranty of")
	call add(header, "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the")
	call add(header, "GNU General Public License for more details.")
	call add(header, "")
	call add(header, "You should have received a copy of the GNU General Public License along")
	call add(header, "with this program; if not, write to the Free Software Foundation, Inc.,")
	call add(header, "51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.")
	call add(header, "")

	try
		call append(0,header)
	   	exe "%s/year.*/" . strftime("%Y") . "> <" . expand("$USER") . ">/ge"

		normal G		
	
	catch /.*/
		echo v:exception
	endtry

endfunction

"Insert GNU header on head of m script with Octave citation
function InsertOctaveFce()
	try

	  let octTempl=expand('~/vimfiles/templ/') . 'oct_header.skel'
	  if filereadable(octTempl)
			 " Vlozi na zacatek text ze souboru bash_script.skel			 
			 exe "0r " . expand(octTempl)
	  else
			 echo "Octave skeleton don't exist!\nInsert head failed!"
			 return 0
	  endif
	  
	  let descript = input("Input your description! ", "")

	  "Nahradi jednotlive texty za adekvatni hodnoty promennych
	  exe "%s/FCENAME/" . expand("%:t:r")."/ge"
	  exe "%s/FILENAME/" . expand("%:t") . "/ge"
	  exe "%s/DATE/" . strftime("%d.%m.%Y %H:%M:%S")  . "/ge"
	  exe "%s/USER/" . expand("$USER") . "/ge"
	  exe "%s/DOMAIN/" . expand("$HOST") . "/ge"
	  exe "%s/DESCR/" . descript . "/ge"

	catch /.*/
		echo v:exception
	endtry

endfunction

"Insert SQL header on head of script
function SQL_header()
	   let HEADER = []
	   call add(HEADER, "-- ******************************************************************")
	   call add(HEADER, "--")
	   call add(HEADER, "-- Title       : ")
	   call add(HEADER, "-- Description : ")
   	   call add(HEADER, "-- System      : N'One System")
	   call add(HEADER, "-- Date        : ")
	   call add(HEADER, "-- Author      : Michal Nadvornik")
	   call add(HEADER, "--")	   
	   call add(HEADER, "-- $Revision: /main/NS_I/1 $")	   
	   call add(HEADER, "-- $Log:  $ ")
	   call add(HEADER, "")
	   call append(0, HEADER)	   

	   exe "%s/-- Title.*/-- Title       : " . expand("%:t") . "/ge"
	   exe "%s/-- Date.*/-- Date        : " . strftime("%d.%m.%Y")  . "/ge"
	   let descript = input("Input your description! ", "")
	   exe "%s/-- Description.*/-- Description : " . descript . "/ge"
endfunction

function SQLHeadUpdate()
	   exe "%s/-- Title.*/-- Title       : " . expand("%:t") . "/ge"
	   exe "%s/-- Date.*/-- Date        : " . strftime("%d.%m.%Y")  . "/ge"
endfunction

"Insert CPP header on head of script
function CPP_Header()
	   let HEADER = []
	   call add(HEADER, "// *************************************************************************")
	   call add(HEADER, "// *                                                                       *")
	   call add(HEADER, "// * This is an unpublished work, the copyright in which vests in AIT Ltd. *")
	   call add(HEADER, "// * All rights reserved. The information contained herein is the property *")
	   call add(HEADER, "// * of AIT Ltd., and no part may be reproduced, used or disclosed, except *")
	   call add(HEADER, "// * as authorised by contract or other written permission.  The copyright *")
	   call add(HEADER, "// * and the foregoing restriction on reproduction, use and disclosure     *")
	   call add(HEADER, "// * extend to all the media in which this information may be embodied.    *")
	   call add(HEADER, "// * Some material contained within is the copyright of other parties, and *")
	   call add(HEADER, "// * such material may not be reproduced, used or disclosed except as      *")
	   call add(HEADER, "// * agreed with those parties.                                            *")
	   call add(HEADER, "// *                                                                       *")
	   call add(HEADER, "// *************************************************************************")
	   call add(HEADER, "//")
	   call add(HEADER, "// Title       : ")
	   call add(HEADER, "// Description : ")
	   call add(HEADER, "// System      : N'One System")
	   call add(HEADER, "// Date        : ")
	   call add(HEADER, "// Author      : Michal Nadvornik")
	   call add(HEADER, "//")
	   call add(HEADER, "// $Revision: /main/NS_I/1 $")
	   call add(HEADER, "// $Log:  $")
	   call add(HEADER, "// ")
	   call add(HEADER, "// ------------------------------------------------------------------------")
	   call add(HEADER, "")
	   call append(0, HEADER)
	   exe "%s/Title.*/Title       : " . expand("%:t") . "/ge"
	   exe "%s/Date.*/Date        : " . strftime("%d %B %Y")  . "/ge"
	   let descript = input("Input your description! ", "")
	   exe "%s/Description.*/Description : " . descript . "/ge"
	   normal G
endfunction	   

"Insert HTML header on head of script
function IniHTMLPage()
	   let body = []
	   call add(body, "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">")
	   call add(body, "<html>")
	   call add(body, "	 <head>")
   	   call add(body, "	 <meta http-equiv=\"content-type\" content=\"text/html; charset=windows-1250\">")
   	   call add(body, "	 <title>TEMPL_TITLE</title>")
	   call add(body, "	 </head>")
	   call add(body, "	 <body>")
	   call add(body, "")
   	   call add(body, "  </body>")
	   call add(body, "</html>")
	   call append(0, body)

	   let title = input("Input title page: ", "")
	   exe "%s/TEMPL_TITLE/" .title . "/ge"

endfunction

function InsertHtmlHead()
	   let body = []
	   call add(body, "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">")
	   call add(body, "<html>")
	   call add(body, "	 <head>")
   	   call add(body, "	 <meta http-equiv=\"content-type\" content=\"text/html; charset=windows-1250\">")
   	   call add(body, "	 <title>TEMPL_TITLE</title>")
	   call add(body, "	 </head>")
	   call add(body, "	 <body>")
	   call add(body, "")
	   call append(0, body)
	   let title = input("Input title page: ", "")
	   exe "%s/TEMPL_TITLE/" .title . "/ge"
   	   normal G
endfunction

"Insert HTML header on down script
function InsertHtmlFoot( )
	   
	let lstline=line('$')
	let foot = []
	call add(foot, "")
	call add(foot, "  </body>")
	call add(foot, "</html>")
	call append(lstline, foot)

endfunction	   

function GetLine()
	   return line(".")
endfunction

function GetLastLine()
	   return line("$")
endfunction

"Insert bash header on top file
function InsertBashHead()
	try

	  let BashTempl=expand('~/vimfiles/templ/') . 'bash_script.skel'
	  if filereadable(BashTempl)
			 " Vlozi na zacatek text ze souboru bash_script.skel			 
			 exe "0r " . expand(BashTempl)
	  else
			 echo "Bash skeleton don't exist!\nInsert head failed!"
			 return 0
	  endif
	  
	  "Nahradi jednotlive texty za adekvatni hodnoty promennych
	  exe "%s/FILENAME/" . expand("%:t") . "/ge"
	  exe "%s/DATE/" . strftime("%d.%m.%Y %H:%M:%S")  . "/ge"
	  exe "%s/DEVELOPER/" . $USER . "/ge"		
	  let descript = input("Input your description! ", "")
	  exe "%s/DESCRIPTION.*/" . descript . "/ge"
	  exe "%s/RENAME/" . expand("%:t:r")."/ge"
	  exe "%s/SCRIPTNAME/" . expand("%:t:r")."/ge"

	catch /.*/
		echo v:exception
	endtry

	return 0

endfunction

	
function InsBashStartScript()
	try
	  let BashTempl=expand('~/vimfiles/templ/') . 'start_script_skeleton.sh'
	  if filereadable(BashTempl)
			 "echo expand(BashTempl)
			 exe "0r " . expand(BashTempl)
	  else
			 echo "Bash start script skeleton don't exist!\nInsert head failed!"
			 return 0
	  endif

	
	catch /.*/
		echo v:exception
	endtry
	  
endfunction



function CreatePythonClass()
	  echo 'Insert python template class into this named file.'
	  echo 'Function exceptation one input parameter which is class name'
	  let classname=input("Insert name of new class: ", "")
	  call _insert_py_class(classname)
endfunction


function _insert_py_class(classname)
	if !exists('a:classname')
		let clsname = input("Insert name of class: ", "")
  else
	   let clsname = a:classname
	endif

	try
	  "Nacte nazev sablony
	  let PyClassTempl=expand('~/vimfiles/templ/') . 'python_class.py'
	  if filereadable(PyClassTempl)
			 echo expand(PyClassTempl)
	  "Nacte obsah sablony
			 exe "0r " . expand(PyClassTempl)
	  else
			 echo "Python class skeleton don't exist!\nInsert head failed!"
			 return 0
	  endif

	  let descript = input("Input your description! ", "")

	  "Nahradi jednotlive texty za adekvatni hodnoty promennych	  
	  exe "%s/DATE/" . strftime("%d.%m.%Y %H:%M:%S")  . "/ge"
	  exe "%s/CLASSNAME/" . clsname . "/ge"
	  exe "%s/USER/" . expand('$USER') . "/ge"
	  exe "%s/HOST/" . expand('$HOST') . "/ge"
	  exe "%s/DESCRIPT/" . descript . "/ge"
	  exe "%s/CODING/" . expand('$LANG') . "/ge"
	  exe "%s/ORGANIZATION/" . "SKODA POWER" . "/ge" 
	  
"	  let exec = /"/usr/bin/python"
"	  exe /"%s/EXECUTE*/" . exec . /"/ge"
	  
	catch /.*/
		echo v:exception
	endtry

endfunction
