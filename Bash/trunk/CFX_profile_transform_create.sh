#!/bin/bash
#:
#: Title			: CFX_profile_transform_create.sh
#: Date			: 27.06.2014 11:21:02
#: Version		: 1.0
#: Developer	: mnadvornik
#: Description	: Script create file for transform profile in CFX pre
#: Options		: 
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
declare LOGFORMAT="%s|%s| %s |%s\n"
declare DIVIDE="===================================\n"
declare ACTUAL_DIR=$(pwd)
declare LOG_FILE=$ACTUAL_DIR/"CFX_profile_transform_create.log"
declare STATUS="INFO"
declare MSG
declare TODAY=$(date '+%d.%m.%Y %H:%M:%S')
declare SCRIPTCFG="$HOME/Data/CFX_profile_transform_create.cfg"
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
			 msg='NEED INPUT PARAMETER WHICH IS DOPLNIT!!'
			 echo $msg
			 echo 'INSERT PATH OF DIRECTORY WITH RESULTS'
			 read RESULTDIR
	  else
			 RESULTDIR="${1:-""}"
	  fi
}


###############################################################################################
# MAIN ACTION PART
###############################################################################################

#LogMsg $STATUS "------ SCRIPT CFX_profile_transform_create STARTED ------"

#debug flag start
#set -x

#debug flag stop
#set +x

#CfgRead

#tests your inputs
#test_inputs $@

declare TEMPL=/windows/D/Codes/noneswtools/Bash/trunk/transform_profile_data.pre
declare CFXPREBIN=/opt/sw/ansys_inc-15/v150/CFX/bin/cfx5pre

declare NODEDIR=/mnt/data3/cfd/WORK/2014/2014_029_SPWR_Modul5_L-0_flutter/SETTINGS/Node/Freq1
declare DIRECTORY=$NODEDIR

declare NEWNAME=$DIRECTORY/"M5_profiles_transform.pre"
declare BLADECOUNT=64



awk 'NR < 8 {print $0}' $TEMPL > $NEWNAME


for item in `find $NODEDIR -type f -regex '.*ND[0-9]+.csv'`
	  do 
			 NAME=$(basename $item | cut -d \. -f 1) 	
			 NEWFILE=$(dirname $item)/$NAME"_64.csv"
			 
			 awk -v OLDFILE=$item -v NEWFILE=$NEWFILE -v BLADECNT=$BLADECOUNT 'NR >= 8 { if($0 ~ /ProfileName/) {  sub(/OLDPRFILE/,OLDFILE,$0); print } \
								 else if($0 ~ /ComponentsIn360/) { sub(/CMPTNNUMB/,BLADECNT,$0); print  } \
								 else if($0 ~ /NewProfileDataPath/) { sub(/NEWPRFILE/,NEWFILE,$0); print } \
								 else {print $0} } ' $TEMPL >> $NEWNAME

			 echo "MODE $NAME WAS APPEND TO BASE SCRIPT"

			 printf "\n\n" >> $NEWNAME

done

if [[ $? -eq 0 && -f $NEWNAME ]]; then
	  echo "BASE SCRIPT $NEWNAME EXECUTE START"
	  $CFXPREBIN -batch $NEWNAME 1>>$LOG_FILE 2>&1
fi

#End section
wait ${!}
#LogEnd
exit 0 
