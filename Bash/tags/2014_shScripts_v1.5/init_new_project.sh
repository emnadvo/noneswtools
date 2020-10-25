#!/bin/bash
#:
#: Title			: init_new_project.sh
#: Date			: 18.05.2012 14:12:58
#: Version		: 1.0
#: Developer	: mnadvornik
#: Description	: Script for initialize new project directory in root directory.
#: Options		: 
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
declare LOGFORMAT="%s|%s| %s |%s\n"
declare DIVIDE="===================================\n"
declare ACTUAL_DIR=$(pwd)
declare LOG_FILE=./"init_new_project.log"
declare STATUS="INFO"
declare MSG
declare TODAY=$(date '+%d.%m.%Y %H:%M:%S')
declare SCRIPTCFG="$HOME/Data/init_new_project.cfg"
declare -a SCRPROPERTY
declare ARRAYSIZE=0
declare DIRRIGHTS=777

declare WORKDIR="/mnt/data3/cfd/WORK"
declare CURRYEAR=`date '+%Y'`

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
			 for line in `awk '$0 !~ /#/ {print $0}' $SCRIPTCFG 2>>$LOG_FILE`			 
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
	  #tests your inputs
	  #@param1 directory with results

	  if [ -z "$@" ]
	  then
			 msg='NEED INPUT PARAMETER WHICH IS NAME FOR NEW PROJECT'
			 echo $msg
			 echo 'INSERT NEW NAME FOR YOUR PROJECT'
			 read NEWNAME
	  else
			 NEWNAME="${1:-""}"
	  fi
}

function get_maxProjectID {
	  #function for finding max value for calculation project
	  #@param1: directory with all projects
	  WORKDIR=${1:-"NONE"}
	  MAXWORKID=`find $WORKDIR/ -maxdepth 1 -type d -regex '.*20[0-9][0-9]_[0-9]+.*' -printf '%f\n' | sort | tail -n 1 | cut -d '_' -f 2 2>>$LOG_FILE`
	  if [[ -n "$MAXWORKID" && ${MAXWORKID:0:1} -eq 0 ]]; then
			 MAXWORKID=${MAXWORKID:1:2}
			 if [[ -n "$MAXWORKID" && ${MAXWORKID:0:1} -eq 0 ]]; then
					MAXWORKID=${MAXWORKID:1:2}
			 fi
	  fi
}

###############################################################################################
# MAIN ACTION PART
###############################################################################################

#LogMsg $STATUS "------ SCRIPT init_new_project STARTED ------"

#debug flag start
#set -x

#debug flag stop
#set +x

#CfgRead

#tests your inputs
test_inputs $@

CURRWRKDIR=$WORKDIR/$CURRYEAR

if [ ! -d $CURRWRKDIR ]; then
	  printf "WORK DIRECTORY (%s) COULD NOT BE FOUND!\nPROGRAM ABORTED!" "$CURRWRKDIR"
	  exit 1
else
	  cd $CURRWRKDIR
	  get_maxProjectID "$CURRWRKDIR"
fi

PROJID=${MAXWORKID:-0}
let PROJID++

printf "NEW PROJECT ID IS %d\n" "$PROJID"

printf "DO YOU WANT TO CHANGE IT? [no] "
read CHANGEID

if [ -n "$CHANGEID" ]; then
	  printf "SET NEW ID\n"
	  read PROJID
fi

if [ $PROJID -lt 100 ]; then
	  if [ ${#PROJID} -eq 1 ]; then
			 NEWPROJID=00$PROJID		 
	  elif [ ${#PROJID} -eq 2 ]; then
			 NEWPROJID=0$PROJID
	  fi
else
	  NEWPROJID=$PROJID
fi

NEWDIRNAME="$CURRYEAR"_"$NEWPROJID"_"$NEWNAME"
STATUS=0

while [ $STATUS -ne 0 ]
do
	  if [ -d $NEWDIRNAME ]; then
			 printf "DIRECTORY (%s) WITH SAME NAME EXIST!\nCHANGE YOUR NAME." "$NEWDIRNAME"
			 echo 'INSERT NEW NAME FOR YOUR PROJECT'
			 read NEWNAME
			 NEWDIRNAME="$CURRYEAR_$NEWPROJID_$NEWNAME"
	  else
			 STATUS=1
	  fi
done			 

#mkdir -p --mode=$DIRRIGHTS $NEWDIRNAME 2>>$LOG_FILE
mkdir -p --mode=$DIRRIGHTS $NEWDIRNAME/SETTINGS 2>>$LOG_FILE
#mkdir -p --mode=$DIRRIGHTS $NEWDIRNAME/SOLUTION 2>>$LOG_FILE
mkdir -p --mode=$DIRRIGHTS $NEWDIRNAME/SOLUTION/Calculation $NEWDIRNAME/SOLUTION/Mesh 2>>$LOG_FILE
mkdir -p --mode=$DIRRIGHTS $NEWDIRNAME/RESULTS 2>>$LOG_FILE

PROJECTDESCR=$NEWDIRNAME/SETTINGS/Project_description.txt
touch $PROJECTDESCR

# WRITE HEADER OF PROJECT DESCRIPTIONS
s=$( printf "%100s" )
printf "#/bin/vim\n" >> $PROJECTDESCR
printf "\n${s// /#}\n#\n" >> $PROJECTDESCR
printf "# CREATED WHEN:\t\t%s\n" "$(date)" >> $PROJECTDESCR
printf "# CREATED BY:\t\t\t%s\n" "$LOGNAME" >> $PROJECTDESCR
printf "# NAME OF PROJECT:\t%s\n#" "$NEWDIRNAME" >> $PROJECTDESCR
printf "\n${s// /#}\n" >> $PROJECTDESCR
# END OF HEADER PART


if [ $? -eq 0 ]; then
	  printf "ID OF NEW PROJECT WAS %s\n" "$PROJID"
fi

echo "PROGRAM FINISHED."

#End section
wait ${!}
#LogEnd
exit 0


