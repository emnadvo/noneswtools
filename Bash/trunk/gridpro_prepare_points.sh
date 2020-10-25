#!/bin/bash
#:
#: Title			: gridpro_prepare_points
#: Date			: 11.12.2014 10:39:25
#: Version		: 1.2
#: Developer	: mnadvornik
#: Description	: Script for points preparation for using in Gridpro
#: Options		: 
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
declare LOGFORMAT="%s|%s| %s |%s\n"
declare DIVIDE="===================================\n"
declare ACTUAL_DIR=$(dirname $(readlink -f $0))
declare LOG_FILE=$ACTUAL_DIR/".log"
declare STATUS="INFO"
declare MSG
declare TODAY=$(date '+%d.%m.%Y %H:%M:%S')
declare SCRIPTCFG="$HOME/Data/.cfg"
declare -a SCRPROPERTY
declare ARRAYSIZE=0

declare JOURNALTEMP=/windows/D/Codes/noneswtools/Bash/trunk/TGambit_template.jou
declare AWKSCRIPT=/windows/D/Codes/noneswtools/Bash/trunk/trn_file_filtering.awk

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
			 for line in `awk '$0 !~ /#.*/ {print $0}' $SCRIPTCFG 2>>$LOG_FILE`			 
			 do
					SCRPROPERTY[a]=$line
	  	  			let a++					
			 done

			 LogMsg $STATUS "$MSG"
 			 ARRAYSIZE=${#SCRPROPERTY[*]}

			 MSG=("END READ SECTION FROM FILE "$SCRIPTCFG" - OK.\nREAD $ARRAYSIZE ITEMS.\n")
			 printf "$MSG"
	  fi
}

function test_inputs {
	  
	  # FULLNAME=${1:-"Unknown Property"}
	   
	  #tests your inputs
	  #@param1 directory with results

	  if [ -z "$@" ]
	  then
			 msg='NEED INPUT PARAMETER WHICH IS ORIGINAL .d FILE WITH POINTS!'
			 echo $msg
			 echo 'INSERT .d FILENAME '
			 read INPUTVAL
	  else
			 INPUTVAL="${1:-""}"
	  fi
}



###############################################################################################
# MAIN ACTION PART
###############################################################################################

#declare CONFIG_FILE=$1
#if [ ! -f $CONFIG_FILE ]; then
#	  echo "CONFIG FILE FOR PROGRAM IS INVALID OR INCORRECT SET! PROGRAM ABORTED!"
#	  exit 1
#fi
# config file correct - parse values example of use
#declare LICENSE_SERVER=`awk 'BEGIN { FS = "=" }; $0 ~ /LICADRESS/ {print $2}' $CONFIG_FILE`

#LogMsg $STATUS "------ SCRIPT  STARTED ------"

#debug flag start
#set -x

#debug flag stop
#set +x

#CfgRead

#tests your inputs
test_inputs $@

NAME=$(basename $INPUTVAL | cut -d \. -f 1)
CWDIR=$(dirname $INPUTVAL)

OUTPUTFILE=$CWDIR/$NAME.dat
JOURNALFINAL=$CWDIR/$NAME.jou
TRNFILENAME=$CWDIR/$NAME.trn

if [[ ! -f $AWKSCRIPT || ! -f $JOURNALTEMP ]]; then
	  echo "YOUR TEMPLATE FILE OR AWK SCRIPT FILE IS INVALID! CHECK SETTING"
fi

if [ ! -f $INPUTVAL ]; then 
	  echo "YOUR FILENAME IS INVALID! IT MUST BE CHECKED MANUALLY! PROGRAM ABORTED!"
	  exit 1
else
	  dos2unix -o $INPUTVAL
	  awk 'NF==2{ print $1,$2,"0.0" }' $INPUTVAL > $OUTPUTFILE
fi

echo "YOUR POINTS ARE PREPARED"

if [ ! -f $JOURNALTEMP ]; then
	  echo "PROBLEM WITH YOUR TEMPLATE OF GAMBIT JOURNAL! IT MUST BE CHECKED MANUALLY"
	  exit 2
else
	  sed "15,16s/\$fnamesig/\$fnamesig=\"$NAME\"/" $JOURNALTEMP > $JOURNALFINAL

	  GAMBITCMD=$(which gambit)
	  if [[ -n "$GAMBITCMD" && -f $JOURNALFINAL ]]; then
			 ACTDIR=$(pwd)
			 cd $CWDIR
			 $GAMBITCMD -inp $JOURNALFINAL
	  fi
fi

echo "JOURNAL FILE ADJUST"

if [ ! -f $TRNFILENAME ]; then
	  echo "OUTPUT FROM GAMBIT DIDN\'T EXIST! PROGRAM ABORTED!"
	  exit 3
else
	  awk -f $AWKSCRIPT  $TRNFILENAME > tempfile

	  MAXLINE=$(wc -l ./tempfile | cut -d " " -f 1)
	  let MAXLINE=$MAXLINE-4

	  echo "$MAXLINE 1" | cat - tempfile > $OUTPUTFILE

	  if [ -f tempfile ]; then
			 rm tempfile
	  fi	  
fi

echo "PROGRAM FINISHED OK!"

#End section
wait ${!}
#LogEnd
exit 0
