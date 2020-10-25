#!/bin/bash
#:
#: Title			: results_export.sh
#: Date			: 06.10.2011 10:37:55
#: Version		: 1.0
#: Developer	: mnadvornik
#: Description	: Script for archiving and sending to customer
#: Options		: 
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
declare LOGFORMAT="%s|%s| %s |%s\n"
declare DIVIDE="===================================\n"
declare ACTUAL_DIR=$(pwd)
declare LOG_FILE=$ACTUAL_DIR/"results_export.log"
declare STATUS="INFO"
declare MSG
declare TODAY=$(date '+%d.%m.%Y %H:%M:%S')
declare SCRIPTCFG="$HOME/Data/results_export.cfg"
declare -a SCRPROPERTY
declare ARRAYSIZE=0
declare RESULTSDIR
declare BLADE_NAME
declare -a ALL_ITEMS
declare CUSTOMDIRECTORY="CFD_results"


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
 			 ARRAYSIZE=${#SCRPROPERTY[*]}
	  fi
}

FIND_DIRNAME='data_results'

###############################################################################################
# MAIN ACTION PART
###############################################################################################

LogMsg $STATUS "------ SCRIPT results_export STARTED ------"

#debug flag start
#set -x

#debug flag stop
#set +x

#CfgRead

if [ -z "$@" ]
 then
	  msg="NEED INPUT PARAMETER WHICH IS MAIN DIRECTORY WITH CALCULATION VARIANTS AND RESULTS."
	  echo $msg
	  STATUS="FATAL"
	  LogMsg $STATUS "$msg SCRIPT FAILED!"
	  exit 2
fi

RESULTSDIR=$1

if [ ! -d $RESULTSDIR ]
then 
	  msg="YOUR DIRECTORY ($RESULTSDIR) NOT EXIST OR IS NOT CORRECT SET!\n"
	  echo $msg
	  STATUS="ERROR"
	  LogMsg $STATUS "$msg SCRIPT ENDED!"
	  exit 3
else
	  STATUS="INFO"
	  cd $RESULTSDIR
	  LogMsg $STATUS "PROCESSING $RESULTSDIR DIRECTORY"
	  BLADE_NAME=$(expr "$RESULTSDIR" : '.*\([A-Z][A-Z][a-z]\(_[0-9]\{3\}\)\(_[0-9]\{4\}\)\(_[0-9]\{3\}\)\{2\}\+\(_[a-z]\{3\}\)\+\(_[a-z0-9]\+\)\?\)')

#	  BLADE_NAME=$(expr "$RESULTSDIR" : '.*\(R[A-Z][a-z]\(_[0-9]\{3\}\)\{4\}\+\(_[a-z]\{3\}\)\?\)')
#	  BLADE_NAME=$(expr "$RESULTSDIR" : '.*\(VS33...[0-9].[0-9]\{2\}\)')
#	  BLADE_NAME=$(expr "$RESULTSDIR" : '.*\(Amager...[0-9].[0-9]\{2\}\)')
#	  BLADE_NAME=$(expr "$RESULTSDIR" : '.*\(TO3a.*.[0-9]\{3\}\)')
	  a=0
#	  for ITEM in `find $RESULTSDIR -type d -name "$FIND_DIRNAME" -printf "%P\n"`

# FIRST STEP - COPY ALL RESULTS FILE TO DIRECTORY PROFILEID/CFD_results/regime
	  for ITEM in `find $RESULTSDIR -type d -name "$FIND_DIRNAME" -printf "%P\n"`
	  do 
			 STARTDIR=$(dirname $(dirname $ITEM))

#			 echo $ITEM
#			 cd $RESULTSDIR/$ITEM
			 
			 REGIME=$(expr "$ITEM" : '.*\(Re[0-9]\+e3.Ma[0-9]\+.*[0-9]\)')
			 RESDIR=$STARTDIR/$CUSTOMDIRECTORY/$REGIME

			 printf "ADD REGIME %s TO ARCHIVE %s\n" "$REGIME" "$BLADE_NAME"

			 if [ ! -d $RESDIR ]
			 then
					mkdir -p $RESDIR
			 fi

			 for file in $(ls -1 $RESULTSDIR/$ITEM)
			 do
					cp $RESULTSDIR/$ITEM/$file $RESDIR
					ALL_ITEMS[a]=$RESDIR/$file
					#ALL_ITEMS[a]=$RESULTSDIR/$ITEM/$file
					let a+=1		
			 done

#			 ALL_ITEMS[a]=$RESDIR
#			 let a+=1
			 
	  done


# DETERMINE FULL PATH OF CFD_results DIRECTORY
	  ARCHDIR=$(find $STARTDIR -type d -name "$CUSTOMDIRECTORY" -printf "%p\n")
#	  echo $ARCHDIR


#	  echo ${ALL_ITEMS[*]}
#exit

# SAVE ALL FILES TO ARCHIVE
	  if [[ ${#ALL_ITEMS[*]} -ne 0 ]]
#	  if [ -d $ARCHDIR ]
	  then
#			 zip -r $RESULTSDIR/$BLADE_NAME.zip ${ALL_ITEMS[*]} >>$LOG_FILE &2>>$LOG_FILE
			 zip -rAm $RESULTSDIR/$BLADE_NAME.zip $ARCHDIR >>$LOG_FILE &2>>$LOG_FILE

#			 tar -cvzf $RESULTSDIR/$BLADE_NAME.tar.gz ${ALL_ITEMS[*]} >>$LOG_FILE &2>>$LOG_FILE
#			 tar -cvjf $RESULTSDIR/$BLADE_NAME.tar.bz2 ${ALL_ITEMS[*]} >>$LOG_FILE &2>>$LOG_FILE
#			 tar -cvaf $RESULTSDIR/$BLADE_NAME.tar.bz2 ${ALL_ITEMS[*]} >>$LOG_FILE &2>>$LOG_FILE
#			 echo ${ALL_ITEMS[*]}

			 wait ${!}

			 if [ $? -eq 0 ]; then
					msg=`printf "ARCHIVE %s.zip WAS CREATED WITH %5s ITEMS.\n" $BLADE_NAME ${#ALL_ITEMS[*]}`
#					rm -rf $ARCHDIR
			 else
					msg=`printf "RETURN CODE %s\nARCHIVE %s.zip WAS NOT CREATED CORRECTLY!\n" "$?"`
			 fi

			 echo $msg			 
			 LogMsg $STATUS "$msg"
	  fi
fi

wait ${!}

LogEnd


#for ITEM in `find -type d -name Results -printf "%P\n"`; do echo $(expr $ITEM : '.*\(VS33...[0-9].[0-9]\{2\}\)'); done

#for ITEM in `find -type d -name Results -printf "%P\n"`; do echo $(expr $ITEM : '.*\(TO3a.....[0-9].[0-9]\{2\}\)'); done
