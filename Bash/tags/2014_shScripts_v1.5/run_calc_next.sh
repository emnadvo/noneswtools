#!/bin/bash
#:
#: Title			: run_calc_next.sh
#: Date			: 07.12.2011 09:24:59
#: Version		: 1.0
#: Developer	: mnadvornik
#: Description	: Script for next N steps calculations in Numeca inicialize from file
#: Options		: 
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
declare LOGFORMAT="%s|%s| %s |%s\n"
declare DIVIDE="===================================\n"
declare ACTUAL_DIR=$(pwd)
declare LOG_FILE=$ACTUAL_DIR/"run_calc_next.log"
declare STATUS="INFO"
declare MSG
declare TODAY=$(date '+%d.%m.%Y %H:%M:%S')
declare SCRIPTCFG="$HOME/Data/run_calc_next.cfg"
declare -a SCRPROPERTY
declare ARRAYSIZE=0
declare RESULTDIR
declare NEXTSTEPS


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


function test_inputs { 
	  #tests your inputs
	  #@param1 directory with results

	  if [ -z "$@" ]
	  then
			 msg="IT'S NECESSARY SET DIRECTORY WHIT RUN FILE OF CALCULATION WHICH YOU CAN CALCULATE NEXT N STEPS.\n"
			 printf $msg
			 echo 'INSERT PATH OF DIRECTORY WITH RUN FILE'
			 read RESULTDIR
			 echo 'INSERT NEXT CALCULATION STEPS'
			 read NEXTSTEPS
	  else
			 RESULTDIR=${1:-""}
			 NEXTSTEPS=${2:-""}
	  fi

	  if [[ ! -d $RESULTDIR || -z "$NEXTSTEPS" ]]
	  then
			 printf "USING THIS SCRIPT WITH THIS FORM: \"run_calc_next directory/where/LookFor/RunFile nextSteps\n"
			 exit 1
	  fi
}

###############################################################################################
# MAIN ACTION PART
###############################################################################################

#LogMsg $STATUS "------ SCRIPT run_calc_next STARTED ------"

#debug flag start
#set -x

#debug flag stop
#set +x

#CfgRead

#tests your inputs
test_inputs $@

FILE_FILTER='*.run'
ITMAX_FIND='ITMAX.*'
#INIT_SOLUTION_FILE	/home/runfile
INIT_SOLFILE='INIT_SOLUTION_FILE.*'
NEWINIT_SOLFILE='INIT_SOLUTION_FILE\t%s'
#TYPE						const
TYPE='TYPE.*'
NEWTYPE='\t\tTYPE						file'

MACHNUMSTART='05'
REYNOLDS='00100'
echo "NEFUNGUJE NEPRACUJE! NUTNO DODELAT."
exit 1
for runfile in `find $RESULTDIR -type f -name "$FILE_FILTER"`
do
	  bak_runfile="$runfile.bak"	  
	  # create bak runfile
	  cp $runfile $bak_runfile

	  #type file
	  LINENMBR=`sed -n '/NI_BEGIN INITIAL_SOLUTION/,/TYPE/=' $runfile`
	  LINENMBR=`echo $LINENMBR | cut -d \  -f 4`
	  echo $LINENMBR

	  cmdline="$LINENMBR s/const/type/g"
	  sed -n $cmdline $bak_runfile > $runfile

#	  LINENMBR=`sed -n '/THROUGHFLOW_INITIAL_SOLUTION_FILE/,/INITIAL_SOLUTION_FILE/=' $runfile`
#	  LINENMBR=`echo $LINENMBR | cut -d \  -f 2`

#	  cmdline="$LINENMBR s/\/[[:alpha:]]/$runfile/g"
#	  sed $cmdline $bak_runfile > $runfile

	  # complete command parameters for sed program
	  cmdline="/$ITMAX_FIND/{n;s/.*/$NEXTSTEPS/;}"
	  # execute sed command
	  sed $cmdline $bak_runfile > $runfile
	  # erase bak runfile
	  #rm -f $bak_runfile

	  printf "RUNFILE %s WAS CHANGED. ITMAX HAS NEW VALUE %d\n" "$runfile" "$ITEM_NEW"

done


#End section
wait ${!}
#LogEnd
exit 0
