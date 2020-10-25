#!/bin/bash
#:
#: Title			: check_licence.sh
#: Date			: 03.05.2011 14:32:47
#: Version		: 1.0
#: Developer	: mnadvornik
#: Description	: Script for check licence of numeca and other program
#: Options		: 
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
declare LOGFORMAT="%s|%s| %s |%s\n"
declare DIVIDE="===================================\n"
declare ACTUAL_DIR=$(pwd)
declare LOG_FILE="check_licence.log"
declare STATUS="INFO"
declare MSG
declare TODAY=$(date '+%d.%m.%Y %H:%M:%S')
#declare SCRIPTCFG="check_licence.cfg"
declare -a SCRPROPERTY
declare ARRAYSIZE=0

declare LICSERVER="licence04.skoda.cz"
declare MESHPRG="IGG_AUTOGRID5"
declare CALCPRG="Solver"
declare LICAVAILABLECOL=7
declare LICFREECOL=13


#Function for logging any messages
function LogMsg {
	  TODAY=$(date '+%d.%m.%Y %H:%M:%S')
	  if [ ! -f $ACTUAL_DIR/$LOG_FILE ]
	  then
			 printf "$LOGFORMAT" "$TODAY" "$USER" "$1" "$2" > $ACTUAL_DIR/$LOG_FILE
	  else
			 printf "$LOGFORMAT" "$TODAY" "$USER" "$1" "$2" >> $ACTUAL_DIR/$LOG_FILE
			  fi
}

#Function for logging end script
function LogEnd {
	  LogMsg "END" "Script ended correctly!"
	  printf $DIVIDE >> $LOG_FILE
}


###############################################################################################
# MAIN ACTION PART
###############################################################################################

LogMsg $STATUS "------ SCRIPT check_licence.sh"

set -x

if [ -z "$@" ]
 then
	  msg='Need input parameter which is name of checked action mesh/solver or verbose for print cfg settings.'
	  echo $msg
	  LogMsg $STATUS "Script failed! $msg"
	  exit 2
fi

case "$1" in
 mesh)
	msg="Licence check for IGG_AUTOGRID5"
	LogMsg $STATUS "$msg"
	prgname=$MESHPRG
	#lic_issued_col=${SCRPROPERTY[4]}
	#lic_used_col=${SCRPROPERTY[5]}
 ;;
 solver)
	msg="Licence check for Solver"
	LogMsg $STATUS "$msg"
	prgname=$CALCPRG
	#lic_issued_col=${SCRPROPERTY[4]}
	#lic_used_col=${SCRPROPERTY[5]}
 ;;
 *) echo 'UNKNOWN OPERATION! YOU MUST USE PARAMS MESH|SOLVER'
esac


	  #Issued licence
	  check_issued_licence="Find users of program "$prgname""
	  LogMsg $STATUS "$check_issued_licence"

	  lic_issued=`/opt/sw/Fluent.Inc/license/lnia64/lmstat -a | grep 'Users of '$prgname':' |  cut -d ' ' -f "$LICAVAILABLECOL" 2>>$ACTUAL_DIR/$LOG_FILE`

	  LogMsg $STATUS "Total of "$lic_issued" issued licence."

	  #Used licence
	  check_used_licence="Find users of program "$prgname""
	  LogMsg $STATUS "$check_used_licence"

	  lic_used=`/opt/sw/Fluent.Inc/license/lnia64/lmstat -a | grep 'Users of '$prgname':' |  cut -d ' ' -f "$LICFREECOL" 2>>$ACTUAL_DIR/$LOG_FILE`

	  LogMsg $STATUS "Total of "$lic_used" used licence."

	  echo $lic_issued
	  echo $lic_used

	  LogEnd
set +x
exit 0
