#!/bin/bash
#:
#: Title			: numeca_mesh_checked_skewness.sh
#: Date			: 13.08.2014 08:46:49
#: Version		: 1.2
#: Developer	: mnadvornik
#: Description	: Script will checked computation meshes at skewness quality
#: Options		: 
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
declare LOGFORMAT="%s|%s| %s |%s\n"
declare DIVIDE="===================================\n"
declare ACTUAL_DIR=$(dirname $(readlink -f $0))
declare LOG_FILE=$ACTUAL_DIR/"numeca_mesh_checked_skewness.log"
declare STATUS="INFO"
declare MSG
declare TODAY=$(date '+%d.%m.%Y %H:%M:%S')
declare SCRIPTCFG="$HOME/Data/numeca_mesh_checked_skewness.cfg"
declare -a SCRPROPERTY
declare ARRAYSIZE=0
declare BUFFER

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
			 msg='NEED INPUT PARAMETER WHICH IS DIRECTORY WITH ALL MESHES!!'
			 echo $msg
			 echo 'INSERT PATH OF DIRECTORY WITH MESHES'
			 read RESULTDIR
	  else
			 RESULTDIR="${1:-""}"
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

LogMsg $STATUS "------ SCRIPT numeca_mesh_checked_skewness.sh STARTED ------"

#debug flag start
#set -x

#debug flag stop
#set +x

#CfgRead

#tests your inputs
test_inputs $@

echo "WORKING INSIDE DIRECTORY $RESULTDIR, PLEASE WAIT...."
IND=0

for item in `find $RESULTDIR -type f -regex '.*.quality.eport'` 
	  do
			 let IND++
			 LogMsg $STATUS $item
			 BUFFER=$(echo $(basename $item))
			 printf "%s\n"  "$BUFFER"
	  		 LogMsg $STATUS $BUFFER

			 BUFFER=$(grep -ar 'Minimal Skewness  Angle:.*' $item)
			 printf "%s\n"  "$BUFFER"
			 printf "%s\n"  "$BUFFER" >> $LOG_FILE
done

echo "IT WAS FOUND $IND ITEMS"
echo "FINISHED"
	  
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

#End section
wait ${!}
#LogEnd
exit 0


