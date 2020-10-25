#!/bin/bash
#:
#: Title			: solve_resulting.sh
#: Date			: 27.07.2011 14:39:20
#: Version		: 1.0
#: Developer	: mnadvornik
#: Description	: Script for automatic result binding from numeca calculation
#: Options		: 
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
declare LOGFORMAT="%s|%s| %s |%s\n"
declare DIVIDE="===================================\n"
declare ACTUAL_DIR=$(pwd)
declare LOG_FILE=$ACTUAL_DIR/"solve_resulting.log"
declare STATUS="INFO"
declare MSG
declare TODAY=$(date '+%d.%m.%Y %H:%M:%S')
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

CFVIEW_SCRIPT='/windows/D/Codes/doosanskodapower/CascadeCFDAnalyses/trunk/bin/results_bind_ver4.py'
#CFVIEW_SCRIPT='/home/mnadvornik/CALCUL/2011_Automat2D_NumSolver_latest/bin/results_bind_picture_only.py'
BLADE_CHORD=0.05
RESULT_DIR="${1:-""}"

###############################################################################################
# MAIN ACTION PART
###############################################################################################

LogMsg $STATUS "------ SCRIPT solve_resulting STARTED ------"

#debug flag start
#set -x

#debug flag stop
#set +x

#TEST SECTION
if [ ! -f $CFVIEW_SCRIPT ] 
then
	  echo "Script for results processing don\'t exist!\nCheck script setting.\n"
	  exit 1
fi

if [ ! -d $RESULT_DIR ]
then
	  echo "Results dir don\'t exist!\nCheck directory setting.\n"
	  exit 1
fi

for item in `find "$RESULT_DIR" -type d -name 'data_results'` 
do 
	  rm -r $item
	  echo "$item REMOVED." 
done

for RUNFILE in $(find "$RESULT_DIR" -type f -name "*.run" 2>>$LOG_FILE )
do
	  RES_ITEM=${RUNFILE%/*}
	  CGNSFILE=$(expr "$RUNFILE" : '\(.*\([^.run]\)\)').cgns
#	  echo $CGNSFILE
	  if [ -f $CGNSFILE ]
	  then
	  	  if [ -d $RES_ITEM ]
			 then
					BLADE_NAME=$(expr "$RUNFILE" : '.*\([A-Z][A-Z][a-z]\(_[0-9]\{3\}\)\(_[0-9]\{4\}\)\(_[0-9]\{3\}\)\{2\}\+\(_[a-z]\{3\}\)\?\)')
					#BLADE_NAME=$(expr "$RUNFILE" : '\([A-Z]\{6\}\(.[a-z]\{2\}[0-9]\)\(.[0-9]\{2\}\)\?\)')
	  			 #echo $BLADE_NAME
					#OUTPUT=$(/usr/bin/time -f 'Elapsed time=%E [h:mm:ss]\n' 
					/opt/sw/numeca/bin/cfview -macro $CFVIEW_SCRIPT -batch -niversion "90_2" -project $RUNFILE "free" $RES_ITEM $BLADE_CHORD ${BLADE_NAME:-'UNKNOWN_BLADE'} 2>&1
					#)
					#echo "$OUTPUT" >> $LOG_FILE
					echo "ITEM $RUNFILE FINISHED"
	  	  else
	  			 echo "Invalid item result directory"
	  			 exit 1
	  	  fi
	  else
			 echo "FOR ITEM $RES_ITEM NOT EXIST CGNS FILE"
			 echo "ITEM WAS SKIPPED."
	  fi
done
	  
LogEnd
