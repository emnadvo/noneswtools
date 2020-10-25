#!/bin/bash
#:
#: Title			: comparison_2D_cases.sh
#: Date			: 30.05.2014 16:14:00
#: Version		: 1.0
#: Developer	: mnadvornik
#: Description	: Script for 
#: Options		:
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
LOGFORMAT="%s|%s| %s |%s\n"
divide="===================================\n"
LOG_FILE="comparison_2D_script.log"
CFG_FILENAME="none.cfg"
TODAY=$(date '+%d.%m.%Y %H:%M:%S')
declare ACTUAL_DIR=$(dirname $(readlink -f $0))
declare STATUS="INFO"
declare MSG

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
	  printf $divide >> $LOG_FILE
}

function test_inputs { 
	  #tests your inputs
	  #@param1 directory with results

	  if [ -z "$@" ]
	  then
			 msg='NEED INPUT PARAMETER WHICH IS DIRECTORY WITH A RESULTS!'
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

LogMsg $STATUS "------ SCRIPT 2D_profiles_plt_prepare STARTED ------"

#tests your inputs
#test_inputs $@

REGEX_PROFILE_FAMILY='.*2013.*.Amager.*/Results'

for ITEM in `find ./ -type d -regex $REGEX_PROFILE_FAMILY`
	  do 
#			 BLADENAME=$(expr "$ITEM" : '.*\(Amager...[0-9].[0-9]\{2\}\)')
			 BLADENAME=$(expr "$ITEM" : '.*\([A-Z][A-Z][a-z]\(_[0-9]\{3\}\)\(_[0-9]\{4\}\)\(_[0-9]\{3\}\)\{2\}\+\(_[a-z]\{3\}\)\?\)')
			 #BLADENAME=$(expr "$ITEM" : '.*\(R[A-Z][a-z]\(_[0-9]\{3\}\)\{4\}\+\(_[a-z]\{3\}\)\?\)')
			 #BLADENAME=$(expr "$ITEM" : '.*\(VS33.*.[0-9].[0-9]\{2\}\)')

#			 echo $BLADENAME 

			 RECALC_ITEM=`find ./2014_SST_recalculation/ -type d -name $BLADENAME`
			 range_1="using 11:13"

			 find $ITEM -type f -regex "$ITEM/Graphs/Ma[0-9]+.datasource.dat"
