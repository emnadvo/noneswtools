#!/bin/bash
#:
#: Title			: change_item_inrunfile.sh
#: Date			: 12.10.2011 09:47:53
#: Version		: 1.0
#: Developer	: mnadvornik
#: Description	: Script for change item in run files.
#: Options		: 
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
declare LOGFORMAT="%s|%s| %s |%s\n"
declare DIVIDE="===================================\n"
declare ACTUAL_DIR=$(pwd)
declare LOG_FILE=$ACTUAL_DIR/"change_item_inrunfile.log"
declare STATUS="INFO"
declare MSG
declare TODAY=$(date '+%d.%m.%Y %H:%M:%S')
declare SCRIPTCFG="$HOME/Data/change_item_inrunfile.cfg"
declare -a SCRPROPERTY
declare ARRAYSIZE=0


#Function for logging any messages
function LogMsg {
	  TODAY=$(date '+%d.%m.%Y %H:%M:%S')
	  if [ ! -f $LOG_FILE ]
	  then
			 printf "$LOGFORMAT" "$TODAY" "$USER" "$1" "$2" > $LOG_FILE
	  else
			 printf "$LOGFORMAT" "$TODAY" "$USER" "$1" "$2" >> $LOG_FILE
			  fi
}

#Function for logging end script
function LogEnd {
	  LogMsg "END" "Script ended correctly!"
	  printf $DIVIDE >> $LOG_FILE
}

#Function for reading property from any cfg file
function CfgRead {
	  #prikaz nastavi cestu vedouci ke skriptu a je stejna s umistenim skriptu
     SCRIPTCFG=$(dirname $(readlink -f $0))/$SCRIPTCFG
	  if [ -f $SCRIPTCFG ] 
	  then	  
			 MSG="READ DATA FROM CONFIG FILE START "$SCRIPTCFG
			 LogMsg $STATUS "$MSG"
			 a=1
			 while read line
			 do
			 if [ -d $line ] #kdyz vstup je adresar nacist pozadovane soubory
			 then
					cd $line
					for i in $(ls -1 * 2>>$LOG_FILE)
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
# 			 ARRAYSIZE=$(($a-1))\
 			 ARRAYSIZE=${#SCRPROPERTY[*]}
	  fi
}


###############################################################################################
# MAIN ACTION PART
###############################################################################################

#LogMsg $STATUS "------ SCRIPT change_item_inrunfile STARTED ------"

#debug flag start
#set -x

#debug flag stop
#set +x

#CfgRead

FILE_FILTER='*.run'
ITEM_FIND='ITMAX.*'

if [ -z "$2" ]
 then
	  msg='Need input parameters which are directory where look for run file and new number of iterations'
	  echo $msg
	  #LogMsg $STATUS "Script failed! $msg"
	  exit 2
fi

ITEM_NEW=$2
FIND_DIR=$1

for runfile in `find $FIND_DIR -type f -name "$FILE_FILTER"`
do
	  printf "RUNFILE %s WAS CHANGED. ITMAX HAS NEW VALUE %d\n" "$runfile" "$ITEM_NEW"
	  bak_runfile="$runfile.bak"
	  # create bak runfile
	  cp $runfile $bak_runfile
	  # complete command parameters for sed program
	  cmdline="/$ITEM_FIND/{n;s/.*/$ITEM_NEW/;}"
	  # execute sed command
	  sed $cmdline $bak_runfile > $runfile
	  # erase bak runfile
	  rm -f $bak_runfile
done

exit 0


#case "$1" in
#	  start)
#	  ;;
#	  archive)
#	  ;;
#	  archive|start)
#	  ;;
#	  verbose)
#			 echo ${SCRPROPERTY[*]}
#	  ;;
#	  *) echo 'UNKNOWN OPERATION! YOU MUST USE PARAMS START|ARCHIVE'
#esac	  
  
#LogEnd

