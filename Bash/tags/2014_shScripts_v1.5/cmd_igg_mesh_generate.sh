#!/bin/bash
#:
#: Title			: cmd_igg_mesh_generate.sh
#: Date			: 23.05.2012 11:18:30
#: Version		: 1.0
#: Developer	: mnadvornik
#: Description	: Script for mesh generation automaticly
#: Options		: 
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
declare LOGFORMAT="%s|%s| %s |%s\n"
declare DIVIDE="===================================\n"
declare ACTUAL_DIR=$(pwd)
declare LOG_FILE=$ACTUAL_DIR/"cmd_igg_mesh_generate.log"
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

#LogMsg $STATUS "------ SCRIPT cmd_igg_mesh_generate STARTED ------"

#debug flag start
#set -x

#debug flag stop
#set +x

#CfgRead

#tests your inputs
#test_inputs $@

templfile='/home/mnadvornik/Data/NumCalc/ReacTL3/MESH/ReacTL3_templ.trb'
STARTDIR='/home/mnadvornik/Data/NumCalc/ReacTL3/MESH'

for dir in `find $STARTDIR -type d -regex '.*VAR[2-4]'`
do
	  cd $dir
#	  cd $STARTDIR

	  for geomFile in `find ./ -type f -regex '.*ReacTL3_0[2-4].*geomTurbo'`
	  do
			 printf "EXECUTE GEOMETRY %s START\n" "$geomFile"
			 meshfile=`find ./ -type f -regex '.*ReacTL3_var[2-4].*igg'`
			 if [ -f $meshfile ]; then
					IGGCMD=`which igg89_1`
					if [ -n "$IGGCMD" ]; then
						  $IGGCMD -autogrid5 -batch -trb "$templfile" -geomTurbo "$geomFile" -mesh "$meshfile" -print 1>>$LOG_FILE 2>&1 
					fi
			 fi
	  done
done

#End section
wait ${!}
#LogEnd
exit 0
