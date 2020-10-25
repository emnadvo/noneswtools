#!/bin/bash
#:
#: Title			: steamgen_run.sh
#: Date			: 28.01.2011 12:26:21
#: Version		: 1.0
#: Developer	: mnadvornik
#: Description	: Script for executing msteam calculation.
#: Options		:
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
LOGFORMAT="%s|%s| %s |%s\n"
divide="===================================\n"
ACTUAL_DIR=$(pwd)
LOG_FILE=$ACTUAL_DIR/"msteam_calc_run.log"
CFG_FILENAME="$ACTUAL_DIR/msteam_run.cfg"
TODAY=$(date '+%d.%m.%Y %H:%M:%S')

declare STATUS="INFO"
declare MSG
declare STEAMGEN_OUTPUT
declare MSTEAM_OUTPUT
declare DIRRIGHTS=777
declare ARCHIVING

function LogMsg {
	  TODAY=$(date '+%d.%m.%Y %H:%M:%S')
	  if [ ! -f $ACTUAL_DIR/$LOG_FILE ]
	  then
			 printf "$LOGFORMAT" "$TODAY" "$USER" "$1" "$2" > $LOG_FILE
	  else
			 printf "$LOGFORMAT" "$TODAY" "$USER" "$1" "$2" >> $LOG_FILE
	  fi
}

function LogEnd {
	  LogMsg "END" "Script ended correctly!"
	  printf $divide >> $LOG_FILE
}

function Archiving {
	  SOURCE_DIR=${1:-""}
	  PROJECT_NAME=${2:-"DEFAULT_NAME"}
	  declare MAXVAL
	  if [ -d $SOURCE_DIR ]; then
			 cd $SOURCE_DIR
			 declare -a FILES
			 a=0
			 for i in $(ls --ignore=*.tar.bz* -1);
			 do
					if [ -f $i ]
					then
						  FILES[a]=$SOURCE_DIR/$i
						  a=$(($a+1))
					fi
			 done
			 # check when files for archive exist
			 if [ ${#FILES[*]} -eq 0 ]; then 
					return 0
			 fi			 
	  fi

	  if [ -f $PROJECT_NAME.tar.bz2 ]
	  then 
			 MAXVAL=$(ls $PROJECT_NAME.tar.bz2* | wc -l)
			 let MAXVAL=$MAXVAL
			 mv $PROJECT_NAME.tar.bz2 $PROJECT_NAME.tar.bz2.$MAXVAL
	  fi

	  if [ -z $ARCHIVING ]; then
			 tar --create --exclude=*.tar.bz* --bzip2 --remove-files --file $PROJECT_NAME.tar.bz2 * 2>>$LOG_FILE
	  else
			 tar --create --exclude=*.tar.bz* --bzip2 --file $PROJECT_NAME.tar.bz2 * 2>>$LOG_FILE
	  fi

	  return 0
}

function Validate {
	  RDIR=${1:-""}
	  THROWFL=${2:-""}
	  GEOMFILE=${3:-""}
	  BCFL=${4:-""}
	  RESNAME=${5:-""}

	  MSTSOLV=${6:-""}
	  STMGEN=${7:-""}
	  BCSCRT=${8:-""}

	  #Result directory
	  if [ ! -d $RDIR ]; then
			 printf "YOUR RESULT DIRECTORY (%s) NOT EXIST!/nCHECK IT!\nPROGRAM ABORTED!\n" "$RDIR"
			 return 1
	  fi

	  #Throughflow calculation
	  if [ ! -f $THROWFL ]; then
			 printf "YOUR THROUGHFLOW CALCULATION (%s) NOT EXIST!\nCHECK IT!\nPROGRAM ABORTED!\n" "$THROWFL"
			 return 1
	  fi

	  #Geometry file
	  if [ ! -f $GEOMFILE ]; then
			 printf "YOUR FILE WITH GEOMETRY (%s) NOT EXIST!\nCHECK IT!\nPROGRAM ABORTED!\n" "$GEOMFILE"
			 return 1
	  fi

	  #Boundary conditions file
	  if [ ! -f $BCFL ]; then
			 printf "YOUR FILE WITH BOUNDARY CONDITIONS (%s) NOT EXIST!\nCHECK IT!\nPROGRAM ABORTED!\n" "$BCFL"
			 return 1
	  fi

	  #Name of project	  
	  if [ -z "$RESNAME" ]; then
			 printf "YOUR NAME IS NOT SET!\nUSING DEFAULT VALUES.\n"
	  fi
	  
	  #MSteam solver
	  if [ ! -f $MSTSOLV ]; then
			 printf "YOUR MSTEAM SOLVER (%s) NOT EXIST!\nCHECK IT!\nPROGRAM ABORTED!\n" "$MSTSOLV"
			 return 1
	  fi

	  #Steamgen preprocessor
	  if [ ! -f $STMGEN ]; then
			 printf "YOUR STEAMGEN PREPROCESSOR (%s) NOT EXIST!\nCHECK IT!\nPROGRAM ABORTED!\n" "$STMGEN"
			 return 1
	  fi

	  #Boundary conditions parser
#	  if [ ! -f $BCSCRT ]; then
#			 printf "YOUR FILE FOR BOUNDARY CONDITIONS PARSE (%s) NOT EXIST!\nCHECK IT!\nPROGRAM ABORTED!\n" "$BCSCRT"
#			 return 1
#	  fi

	  return 0
}

###############################################################################################
# MAIN ACTION PART
###############################################################################################

#LogMsg $STATUS "SCRIPT steamgen_run.sh started"
declare CONFIG_FILE=`find ./ -type f -name 'bin_settings.cfg'`
if [ ! -f $CONFIG_FILE ]; then
	  echo "CONFIG FILE FOR PROGRAM IS INVALID! PROGRAM ABORTED!" >>$LOG_FILE 
	  exit 1
fi
# config file correct - parse values
# APP SETTINGS
declare MSTEAM=`awk 'BEGIN { FS = "=" }; $0 ~ /MSTEAM/ {print $2}' $CONFIG_FILE`
declare STEAMGEN=`awk 'BEGIN { FS = "=" }; $0 ~ /STEAMGEN/ {print $2}' $CONFIG_FILE`
declare RESPLOT=`awk 'BEGIN { FS = "=" }; $0 ~ /RESPLOT/ {print $2}' $CONFIG_FILE`
# CALC CASE SETTINGS
declare RESDIR=$1
declare NAME=$2
declare BCFILE=$3
declare GEOMETRYFILE=$4
declare THROGHFLOW=$5
ARCHIVING=${6:-""}


NAME=`echo $NAME | sed 's/ *//g'`
declare CURRENT_DIR=`pwd`
# PARSE END

# declare BCPARSE_SCRPT=`awk 'BEGIN { FS = "=" }; $0 ~ /BCPARSE/ {print $2}' $CONFIG_FILE`

printf "VALIDATION START\n"
Validate "$RESDIR" "$THROGHFLOW" "$GEOMETRYFILE" "$BCFILE" "$NAME" "$MSTEAM" "$STEAMGEN"
if [ $? -ne 0 ]; then
	  MSG="INVALID VALIDATION!\n"
	  printf $MSG
	  LogMsg "$STATUS" "$MSG"
	  exit 1
fi
printf "VALIDATION - OK\n"
CALCDIR=$RESDIR/Calc

if [ ! -d $CALCDIR ]; then
	  mkdir --mode=$DIRRIGHTS -p $CALCDIR 2>>$LOG_FILE
fi

printf "ARCHIVE OLD RUNS START\n"
Archiving "$CALCDIR" "$NAME"

#printf "BOUNDARY CONDTIONS PARSE START\n"
#BCPARSE_DIR=`dirname $BCPARSE_SCRPT`
#if [ -d $BCPARSE_DIR ]; then
#	  cd $BCPARSE_DIR

#	  $BCPARSE_SCRPT "$BCFILE" "$THROGHFLOW" "$CALCDIR" "$NAME"
#	  if [ $? -eq 0 ]; then
#			 STMG_IN=`find $CALCDIR -type f -iname "*$NAME.stgin"`
#	  else
#			 STMG_IN=
#			 printf "STEAMGEN PREPROCESSOR FAILED!\nPROGRAM ABORTED!\n"
#			 exit 1
#	  fi
#	  cd $CURRENT_DIR
#fi
#printf "BOUNDARY CONDTIONS PARSE - OK\n"

STMG_IN=`find $RESDIR -type f -iname "*$NAME.stgin"`
STMG_OUT=
printf "STEAMGEN PREPROCESSOR START\n"
if [[ -n "$STMG_IN" && -f $STMG_IN ]]; then
	  STMG_OUT=$CALCDIR/$NAME.stgout
	  $STEAMGEN "$STMG_IN" "$GEOMETRYFILE" "$STMG_OUT"
else
	  printf "MISSING FILE FOR STEAMGEN PREPROCESSOR!\nPROGRAM ABORTED!\n"
	  exit 1
fi
printf "STEAMGEN PREPROCESSOR - OK\n"

MSTEAM_OUT=$CALCDIR/$NAME.mstout
MSTEAM_OUT=`echo $MSTEAM_OUT | tr -d ' '`

STARTTIME=$(date '+%d.%m.%Y %H:%M:%S')
printf "CASE WITH NAME %s CALCULATION START %s\n" "$NAME" "$(date '+%d.%m.%Y %H:%M:%S')" >>$LOG_FILE
printf "MSTEAM CALCULATION (%s) START AT %s\n" "$NAME" "$(date '+%d.%m.%Y %H:%M:%S')"
if [[ $? -eq 0 && -n "$STMG_OUT" && -f $STMG_OUT ]]; then
#	  which vim > /dev/null 2>&1
#	  if [ $? -eq 0 ]; then
#			 vim -n +3 "$STMG_OUT"
#			 wait ${!}
#	  fi
	  #Calc start	  
	  $MSTEAM "$CALCDIR" < "$STMG_OUT" > "$MSTEAM_OUT"
else
	  printf "MISSING FILE FOR MSTEAM SOLVER!\nPROGRAM ABORTED!\n"
	  exit 1
fi

printf "CALCULATION (%s) STOP %s\n" "$NAME" "$(date '+%d.%m.%Y %H:%M:%S')" >>$LOG_FILE
printf "MSTEAM CALCULATION (%s) - STOP AT %s\n" "$NAME" "$(date '+%d.%m.%Y %H:%M:%S')"

printf "PLOT PROCESS START\n"
if [[ $? -eq 0 && -f $RESPLOT ]]; then
	  $RESPLOT "$CALCDIR" "$MSTEAM_OUT"
	  if [ $? -eq 0 ]; then
			 fl=$(ls -1 $CALCDIR/PNGOut/*POWER*.png)
			 which eog > /dev/null 2>&1
			 if [ $? -eq 0 ]; then
					/usr/bin/eog "$fl" & #OPEN WITH PROGRAM EYE OF GNOME 
					wait ${!} 
			 fi
	  fi
fi
printf "PLOT PROCESS FINIHED\n"

exit 0
