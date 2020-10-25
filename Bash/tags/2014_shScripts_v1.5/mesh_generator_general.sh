#!/bin/bash
#:
#: Title			: mesh_generator.sh
#: Date			: 06.02.2014 13:29:00
#: Version		: 1.0
#: Developer	: mnadvornik
#: Description	: Mesh generation script for cascade project
#: Options		: 
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
declare LOGFORMAT="%s|%s| %s |%s\n"
declare DIVIDE="===================================\n"
declare ACTUAL_DIR=$(pwd)
declare LOG_FILE=$ACTUAL_DIR/"mesh_generator.log"
declare STATUS="INFO"
declare MSG
declare TODAY=$(date '+%d.%m.%Y %H:%M:%S')
declare SCRIPTCFG="$HOME/Data/mesh_generator.cfg"
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

#LogMsg $STATUS "------ SCRIPT mesh_generator STARTED ------"

#debug flag start
#set -x

#debug flag stop
#set +x

#CfgRead

#tests your inputs
#test_inputs $@
STARTDIR=`pwd`
BASEDIR=("/mnt/data4/cfd/WORK/2014/2014_016_SPWR_Kelar_v05-NT3_Numeca/SOLUTION/v10" \
)
TEMPLTRB=/mnt/data4/cfd/WORK/2014/2014_016_SPWR_Kelar_v05-NT3_Numeca/SOLUTION/v05/Mesh/Kelar_v05-NT3.trb
#TEMPLTRB=/home/mnadvornik/Data/NumCalc/MeshTemplates/templ_LBk_035_1330_140_241_exp_Re250e3/templ_LBk_035_1330_140_241_exp_Re250e3.trb
NUMECA_VERSION=90_3

for WRDIR in ${BASEDIR[*]}
do

	  cd $WRDIR

for ITEM in `find $WRDIR -type d -regex '.*/Mesh.*' -printf "%p\n"`  #-size 0 
do
	  if [[ "$ITEM" == *.bak.* ||  "$ITEM" == templ.* ]]; then 
			 continue 
	  else
			 
#			 CWRKDIR=$(dirname $(dirname $ITEM))

			 GEOMTURBO=`find $ITEM -type f -regex '.*.[^b][^a][^k].geom.urbo' -printf "%p\n"`

			 NAME=$(basename $GEOMTURBO | cut -d \. -f 1)

			 if [[ -f $GEOMTURBO ]]; then
#			    cd $WRKDIR
			    printf "ITEM: %s START WITH MESH GENERATION\n" "$NAME"
			    igg -niversion $NUMECA_VERSION -autogrid5 -batch -trb $TEMPLTRB -geomTurbo $GEOMTURBO -mesh $ITEM/$NAME -print 1 > $LOG_FILE
			    wait ${!}
#			    cd $STARTDIR
			 fi
	  fi
done

done
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


