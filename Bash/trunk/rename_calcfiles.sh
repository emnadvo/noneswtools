#!/bin/bash
#:
#: Title			: rename_calcfiles.sh
#: Date			: 02.01.2012 08:04:02
#: Version		: 1.0
#: Developer	: mnadvornik
#: Description	: Script for archiving data_results directories.
#: Options		: 
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
declare LOGFORMAT="%s|%s| %s |%s\n"
declare DIVIDE="===================================\n"
declare ACTUAL_DIR=$(pwd)
declare LOG_FILE=$ACTUAL_DIR/"rename_calcfiles.log"
declare STATUS="INFO"
declare MSG
declare TODAY=$(date '+%d.%m.%Y %H:%M:%S')
declare SCRIPTCFG="$HOME/Data/rename_calcfiles.cfg"
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
#			 LogMsg $STATUS "$MSG"
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
#			 LogMsg $STATUS "$MSG"
# 			 ARRAYSIZE=$(($a-1))\
 			 ARRAYSIZE=${#SCRPROPERTY[*]}
	  fi
}


function test_inputs { 
	  #tests your inputs
	  #@param1 directory with results

	  if [ -z "$@" ]
	  then
			 msg='NEED INPUT PARAMETER WHICH IS MAIN DIRECTORY!'
			 echo $msg
			 echo 'INSERT PATH OF DIRECTORY WITH RESULTS..'
			 read RESULTDIR
	  else
			 RESULTDIR="${1:-""}"
	  fi
}

declare NEW_NAME="Re00250e3_Ma040_i000"

###############################################################################################
# MAIN ACTION PART
###############################################################################################

#LogMsg $STATUS "------ SCRIPT extract_results STARTED ------"

#debug flag start
#set -x

#debug flag stop
#set +x

#CfgRead

#/home/mnadvornik/workspace/NOT_USE/TEST_DIR

#tests your inputs
test_inputs $@

if [ -f $LOG_FILE ]; then
	  rm -f $LOG_FILE
fi

old_name=".*Re[0-9]+e3.ver2_re[0-9]+e3.ver2*"
#old_name="Re[0-9]+e3_Re[0-9]+e3"

file_regex=".*Re[0-9]+e3-ver[0-9]_re[0-9]+e3-ver[0-9].*"

sed_cmd="s/Re[0-9]\+e3.ver2_re[0-9]\+e3.ver2/$NEW_NAME/g"
#sed_cmd="s/Re[0-9]\+e3_Re[0-9]\+e3/$NEW_NAME/g"
seddir_cmd="s/Re[0-9]\+/$NEW_NAME/g"
echo $sed_cmd >> $LOG_FILE

if [ -d $RESULTDIR ]
then

	  for dir in `find $RESULTDIR -type d -regex $old_name`
	  do
			 resdir=$(expr "$dir" : '.*\(R[A-Z][a-z]\(_[0-9]\{3\}\)\{4\}\+\(_[a-z]\{3\}\)\?\)')
			 resdir=`find $RESULTDIR -type d -regex ".*$resdir"`
			 resdir=$resdir/Results/$NEW_NAME
			 echo $resdir
			 #new directory create in results directory
			 if [ ! -d $resdir ]; then
					mkdir -pv $resdir >> $LOG_FILE
			 fi
			 #check new dir exist
			 if [ -d $resdir ]; then
					cp -rv $dir/* $resdir >> $LOG_FILE
			 fi

			 for file in `find $resdir -type f -regex $file_regex`
			 do
					NEWFILE=`echo $file | sed $sed_cmd`
					echo $NEWFILE >>$LOG_FILE
					if [ "$file" != "$NEWFILE" ]; then
						  mv -v $file $NEWFILE >>$LOG_FILE
					fi
			 done
			 
			 wait ${!}

			 for file in `find $resdir -type f -regex '.*Re00250e3_Ma040_i000_aver.*'`
			 do
					AVER_RES=$file

					if [ -f $AVER_RES ]; then
						  BACK_AVER="$AVER_RES.bak"

						  cp $AVER_RES $BACK_AVER

						  rm -f $AVER_RES
	  
						  awk '{ if ( $0 ~ /Re00250e3.ver2_re00250e3.ver2/ ) print (NEWVAL); else print $0 }' NEWVAL="$NEW_NAME" $BACK_AVER >> $AVER_RES
						  rm -f $BACK_AVER
					else
						  echo "FILE AVER AND SURF CAN NOT FIND!"
					fi
			 done

			 wait ${!}

			 for file in `find $resdir -type f -regex '.*.surf'`
			 do
					SURF_RES=$file

					if [ -f $SURF_RES ]; then
						  BACK_SURF="$SURF_RES.bak"

						  cp $SURF_RES $BACK_SURF

						  rm -f $SURF_RES
	  
						  awk '{ if ( $0 ~ /Re00250e3.ver2_re00250e3.ver2/ ) print (NEWVAL); else print $0 }' NEWVAL="$NEW_NAME" $BACK_SURF >> $SURF_RES

						  rm -f $BACK_SURF
					else
						  echo "FILE AVER AND SURF CAN NOT FIND!"	 
					fi 
			 done
			 wait ${!}
	  done
else
	  printf "YOUR DIRECTORY WAS WRONG.\nCHECK YOUR PARAMETER."
fi

#End section
wait ${!}
#LogEnd
exit 0


#	  for dir in `find $RESULTDIR -type d -regex '.*Re[0-9]+'`
#	  do
#			 NEWFILE=`echo $dir | sed $seddir_cmd`
#			 echo $NEWFILE >>$LOG_FILE
#			 if [ "$dir" != "$NEWFILE" ]; then
#					mv -v $dir $NEWFILE >>$LOG_FILE
#			 fi
#	  done
