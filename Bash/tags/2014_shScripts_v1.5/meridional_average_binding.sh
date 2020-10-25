#!/bin/bash
#:
#: Title			: cfview_execute_post.sh
#: Date			: 29.05.2012 11:18:30
#: Version		: 1.0
#: Developer	: mnadvornik
#: Description	: Script for postprocessing
#: Options		: 
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
declare LOGFORMAT="%s|%s| %s |%s\n"
declare DIVIDE="===================================\n"
declare ACTUAL_DIR=$(pwd)
declare LOG_FILE=$ACTUAL_DIR/"cmd_cfview_output.log"
declare STATUS="INFO"
declare MSG
declare TODAY=$(date '+%d.%m.%Y %H:%M:%S')
declare SCRIPTCFG="$HOME/Data/cmd_igg_mesh_generate.cfg"
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
			 msg='NEED INPUT PARAMETERS WHICH IS CALCULATION DIRECTORY AND RESULT DIRECTORY!!'
			 echo $msg
#			 echo 'INSERT PATH OF DIRECTORY WITH CALCULATION'
#			 read STARTDIR
			 echo 'INSERT PATH OF DIRECTORY WITH RESULTS'
			 read RESULTDIR
	  else
#			 STARTDIR="${1:-""}"
			 RESULTDIR="${1:-""}"
	  fi

#	  if [ ! -d $STARTDIR ]; then
#			 echo 'YOUR CALCULATION DIRECTORY IS INVALID!'
#			 echo 'PROGRAM ABORTED'
#			 exit 1
#	  fi
}


###############################################################################################
# MAIN ACTION PART
###############################################################################################

#LogMsg $STATUS "------ SCRIPT cmd_igg_mesh_generate STARTED ------"

#debug flag start
#set -x

#debug flag stop
#set +x

#CfgRead

#tests your inputs
#test_inputs $@

#if [ ! -d $RESULTDIR ]; then
#	  mkdir -p $RESULTDIR 2>&1
#fi

# IT'S NECESSARY TO EXECUTE THIS SCRIPT FROM CMD! OTHERWISE YOU GET ERROR FROM OS

SCRIPTFILE='/home/mnadvornik/Data/Numeca_postprocessing/3D_makro_Mach.py'
MESCRIPTFILE='/windows/D/Codes/doosanskodapower/CFVIEW_tools/trunk/Circumferential_Averages.py'
MATLABDIR='/home/mnadvornik/Data/Numeca_postprocessing'
STARTDIR='/mnt/data3/cfd/WORK/2013/2013_009_SPW_Modu5-AxOut/SOLUTION/calculation/Numeca_solution/2014_009_M5_flutter/M5_for_flutter'
REGEX_FILTER='.*_stationar'


#.*Indie660_NT[0-9]+

for dir in `find $STARTDIR -type d -regex "$REGEX_FILTER" -printf '%p\n'`
do
	  cd $dir	  
	  RESULTDIR=Results

	  if [ ! -d $RESULTDIR ]; then
			 mkdir -p $RESULTDIR
	  fi

#	  for runFile in `find ./ -type f -regex '.*run'`
#	  do
#			 dirnm=`dirname $runFile`
#			 printf "EXECUTE RUNFILE %s START\n" "$runFile"
#			 if [ -f $runFile ]; then
#					CFVIEWCMD=`which cfview89_1`
#					if [ -n "$CFVIEWCMD" ]; then
#						  $CFVIEWCMD -macro "$SCRIPTFILE" -batch -project $runFile -resdir "$RESULTDIR"  -print >>$LOG_FILE
#					fi
#			 fi
#	  done

	  for mecfvfile in `find ./ -type f -regex '.*me\.cfv'`
	  do 
			 printf "EXECUTE me.cfv FILE %s START\n" "$mecfvfile"
			 if [ -f $mecfvfile ]; then
					CFVIEWCMD=`which cfview90_3`
					if [ -n "$CFVIEWCMD" ]; then
						  $CFVIEWCMD -macro "$MESCRIPTFILE" -batch -project "$mecfvfile" -print >>$LOG_FILE
					fi
			 fi
	  done

#matlab -nodesktop -nosplash -r "process_efficiency_calc('"testA"','"testB"','"testC"','"testD"','"testAA"','"exit"')"

done

#End section
wait ${!}
#LogEnd
exit 0
