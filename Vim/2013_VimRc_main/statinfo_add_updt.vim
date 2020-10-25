function DateNow()
	call append(line('.'),strftime("%d/%m/%Y %H:%M") )	
	call append(line('$'),'')
	normal G 
endfunction

function StatInfoAdd()
	   "create list special order, because look like better final form
	   let statList = []
	   call add(statList,"**********************************************************************************************")
	   call add(statList, "FILENAME:")
	   call add(statList, "DATETIME CREATED:")
	   call add(statList, "CREATED BY:")
	   call add(statList, "DATETIME UPDATED:")
	   call add(statList, "UPDATED BY:")
	   call add(statList, "")
   	   call add(statList, "**********************************************************************************************")
	   "vlozi list na zacatek souboru
	   call append(0, statList)
	   "nahradi radky zacinajici uvedenymi slovy
	   "/hledane_slovo.*/nahrazovane_slovo "až do konce øádku
	   exe "%s/FILENAME:.*/FILENAME: ".expand("%:t") . "/ge"
	   exe "%s/DATETIME CREATED:.*/DATETIME CREATED: ".strftime("%d\\/%m\\/%Y %H:%M") . "/ge"
   	   exe "%s/CREATED BY:.*/CREATED BY:  ". $USERNAME . "/ge"
   	   exe "%s/DATETIME UPDATED:.*/DATETIME UPDATED: ".strftime("%d\\/%m\\/%Y %H:%M") . "/ge"
	   exe "%s/UPDATED BY:.*/UPDATED BY: " . $USERNAME . "/ge"	   
endfunction

function RecUpdate()
	   "zamena data zmìny
	   exe "%s/DATETIME UPDATED:.*/DATETIME UPDATED: ".strftime("%d\\/%m\\/%Y %H:%M") . "/ge"
	   exe "%s/UPDATED BY:.*/UPDATED BY: " . $USERNAME . "/ge" 
endfunction

function TDE_StatInfoAdd()
	   "create list special order, because look like better final form
	   let statList = []
	   call add(statList,"*******************************************************************************************************")
	   call add(statList, "FILENAME:")
	   call add(statList, "DATETIME CREATED:")
	   call add(statList, "CREATED BY:")
	   call add(statList, "DATETIME UPDATED:")
	   call add(statList, "UPDATED BY:")
    	   call add(statList, "STATUS:")
	   call add(statList, "")
   	   call add(statList, "*******************************************************************************************************")
   	   call add(statList, "WORK REPORT:")
   	   call add(statList, "CODES:")
   	   call add(statList, "KEYWORDS:")
   	   call add(statList, "DESCRIPTION:")
   	   call add(statList, "NOTES:")
   	   call add(statList, "*******************************************************************************************************")
   	   call add(statList, "")
   	   call add(statList, "MAIN:")	   
	   "vlozi list na zacatek souboru
	   call append(0, statList)
	   "nahradi radky zacinajici uvedenymi slovy
	   "/hledane_slovo.*/nahrazovane_slovo "až do konce øádku
	   exe "%s/FILENAME:.*/FILENAME: ".expand("%:t") . "/ge"
	   exe "%s/DATETIME CREATED:.*/DATETIME CREATED: ".strftime("%d\\/%m\\/%Y %H:%M") . "/ge"
   	   exe "%s/CREATED BY:.*/CREATED BY:  ". $USERNAME . "/ge"
   	   exe "%s/DATETIME UPDATED:.*/DATETIME UPDATED: ".strftime("%d\\/%m\\/%Y %H:%M") . "/ge"
	   exe "%s/UPDATED BY:.*/UPDATED BY: " . $USERNAME . "/ge"	   
   	   exe "%s/STATUS:.*/STATUS: NEW/ge"
	   normal G
endfunction

function ActiveStatus()
	   exe "%s/STATUS:.*/STATUS: ACTIVE/ge"
endfunction

function ArchiveStatus()
	   exe "%s/STATUS:.*/STATUS: ARCHIVE/ge"
endfunction
