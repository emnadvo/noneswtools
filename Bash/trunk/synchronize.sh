#!/bin/bash
#:
#: Title			: synchronize.sh
#: Date			: 01.02.2011 10:06:04
#: Version		: 1.0
#: Developer	: mnadvornik
#: Description	: Script for synchronize with other destination.
#: Options		: 
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
declare LOGFORMAT="%s|%s| %s |%s\n"
declare DIVIDE="===================================\n"
declare ACTUAL_DIR=$(pwd)
declare LOG_FILE="synchronize.log"
declare STATUS="INFO"
declare MSG
declare TODAY=$(date '+%d.%m.%Y %H:%M:%S')
declare SCRIPTCFG="$HOME/Data/synchronize.cfg"
declare -a SCRPROPERTY
declare ARRAYSIZE=0
declare DEST='/media/NONESYS_1/Projekty/Power'

function LogMsg {
	  TODAY=$(date '+%d.%m.%Y %H:%M:%S')
	  if [ ! -f $ACTUAL_DIR/$LOG_FILE ]
	  then
			 printf "$LOGFORMAT" "$TODAY" "$USER" "$1" "$2" > $ACTUAL_DIR/$LOG_FILE 
	  else
			 printf "$LOGFORMAT" "$TODAY" "$USER" "$1" "$2" >> $ACTUAL_DIR/$LOG_FILE
	  fi
}

function LogEnd {
	  LogMsg "END" "Script ended correctly!"
	  printf $DIVIDE >> $LOG_FILE
}


function CfgRead {
	  if [ -f $SCRIPTCFG ] 
	  then	  
			 MSG="READ DATA FROM CONFIG FILE START "$SCRIPTCFG
			 LogMsg $STATUS "$MSG"
			 a=0
			 while read line
			 do
			 if [ -d $line ] #kdyz vstup je adresar nacist pozadovane soubory
			 then
					cd $line
					for i in $(ls -1 *.m *.dat *.f *.v07 *.d *.mer07 *.sh *.py *.cfg *.bz2 *.gnpl *.plt 2>>$ACTUAL_DIR/$LOG_FILE)
					do
						  if [ -f $i ]
						  then 
								 SCRPROPERTY[a]=$line/$i
								 a=$(($a+1))
						  fi
					done
			 else
					SCRPROPERTY[a]=$line
					a=$(($a+1))
			 fi
			 done < $SCRIPTCFG
			 MSG=("END READ SECTION FROM FILE "$SCRIPTCFG" - OK")
			 echo $MSG
			 LogMsg $STATUS "$MSG"
			 ARRAYSIZE=$(($a-1))
	  fi
}

function Synchr {
			 MSG="Synchronize process started"
			 LogMsg $STATUS "$MSG"
			 if [ $ARRAYSIZE -gt 0 ]
			 then
					if [ -z $DEST ]
					then
						  echo 'INSERT DESTINATION PATH FOR SYNCHRONIZE: '
						  read DEST
					fi

					if [ ! -d $DEST ]
					then
						  mkdir $DEST 2>>$ACTUAL_DIR/$LOG_FILE
						  echo "DIRECTORY CREATED"
					fi

					echo 'SYNCHRONIZE STARTED'
					echo -n  "PROGRES:  "
					id=0
					while [ $id -le $ARRAYSIZE ]			 
					do
						  let "x=($id/$ARRAYSIZE)*100"
						  rsync -v ${SCRPROPERTY[$id]} $DEST >> $ACTUAL_DIR/$LOG_FILE 2>&1
						  if [ $id -eq 0 ]
						  then
								 echo -en "${x}%"
						  fi
						  id=$(($id+1))
						  echo -en "\b\b${x}%"						  
					done
					echo ""
			 else
					MSG=("DON'T EXIST ANY PROPERTY. SIZE OF PROPERTY ARRAY= "$SCRPROPERTY[0])
					STATUS="ERROR"
					LogMsg $STATUS "$MSG"
			 fi

			 MSG="SYNCHRONIZE PROCESS ENDED"
			 echo $MSG
			 LogMsg $STATUS "$MSG"
}
###############################################################################################
# MAIN ACTION PART
###############################################################################################

LogMsg $STATUS "------ SCRIPT synchronize.sh STARTED ------"

rsync -v $HOME/Data/*.sh  /windows/D/Codes/bsh/ >> $ACTUAL_DIR/$LOG_FILE 2>&1

CfgRead

cd $ACTUAL_DIR

case "$1" in
	  start) 
			 Synchr
	  ;;
	  archive) 			 
	  ;;
	  archive|start) 
			 Synchr
	  ;;
	  verbose)			 
			 echo ${SCRPROPERTY[*]}
	  ;;
	  *) echo 'UNKNOWN OPERATION! YOU MUST USE PARAMS START|ARCHIVE'
esac	  
	  
LogEnd
