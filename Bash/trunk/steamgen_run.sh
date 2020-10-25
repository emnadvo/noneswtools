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
LOG_FILE="steamgen_script.log"
CFG_FILENAME="/home/mnadvornik/Data/stmg_mstg.cfg"
TODAY=$(date '+%d.%m.%Y %H:%M:%S')
ACTUAL_DIR=$(pwd)
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


function CfgRead {
	  if [ -f $CFG_FILENAME ] 
	  then	  
			 MSG="read data from config file "$CFG_FILENAME
			 LogMsg $STATUS "$MSG"
			 a=0
			 while read line
			 do a=$(($a+1))
			 case $a in
					1) STMG_PATH=$line
					;;
					2) STMG_CFG=$STMG_PATH/$line
					;;
					3) STMG_EXE=$STMG_PATH/$line
					;; 
					4) MSTEAM_PATH=$line
					;;
					5) MSTEAM_EXE=$MSTEAM_PATH/$line
					;;
					6) MSTEAM_CFG=$STMG_PATH/$line
					;;
					7) ARCHIVE_PATH=$line/back_$(date +%d%m%y)
					   FINAL_PATH=$line
					   RESULT_PATH=$line/actual
					;;			  
					*) echo 'unset property'
			 esac
			 done < $CFG_FILENAME
			 echo "END READ SECTION SETTINGS FROM FILE - OK"
	  fi

	  if [ -d $STMG_PATH ]
	  then
			 echo 'STEAMGEN PATH: '$STMG_PATH
	  else
			 echo 'STEAMGEN PATH: '$STMG_PATH  " DON'T EXIST"
	  fi

	  if [ -f $STMG_CFG ]
	  then 
			 echo 'STEAMGEN DATA: '$STMG_CFG
	  else
			 echo 'STEAMGEN DATA: '$STMG_CFG " DON'T EXIST!"
	  fi

	  if [ -f $STMG_EXE ]
	  then 
			 echo 'STEAMGEN EXECUTE: '$STMG_EXE
	  else
			 echo 'STEAMGEN EXECUTE: '$STMG_EXE " DON'T EXIST!"
	  fi

	  if [ -d $MSTEAM_PATH ]
	  then 
			 echo 'MSTEAM PATH: '$MSTEAM_PATH
	  else
			 echo 'MSTEAM PATH: '$MSTEAM_PATH " DON'T EXIST!"
	  fi

	  if [ -f $MSTEAM_EXE ]
	  then 
			 echo 'MSTEAM EXECUTE: ' $MSTEAM_EXE
	  else
			 echo 'MSTEAM EXECUTE: ' $MSTEAM_EXE " DON'T EXIST!"
	  fi

#	  if [ -f $MSTEAM_CFG ]
#	  then 
			 echo 'MSTEAM DATA: ' $MSTEAM_CFG
#	  else
#			 echo 'MSTEAM DATA: ' $MSTEAM_CFG " DON'T EXIST!"
#	  fi

	  if [ ! -d $ARCHIVE_PATH ]
	  then
			 mkdir $ARCHIVE_PATH
			 echo 'ARCHIVE PATH: ' $ARCHIVE_PATH
	  else
			 echo 'ARCHIVE PATH: ' $ARCHIVE_PATH ' EXIST'
	  fi

	  if [ ! -d $RESULT_PATH ]
	  then
			 mkdir $RESULT_PATH
			 echo 'RESULT PATH: ' $RESULT_PATH
	  else
			 echo 'RESULT PATH: ' $RESULT_PATH ' EXIST'
	  fi
}


function Archiving {

	  cd $STMG_PATH

	  declare -a FILES
	  a=0
	  for i in $(ls -1);
	  do
			 if [ -f $i ]
			 then
			 		FILES[a]=$STMG_PATH/$i
					a=$(($a+1))
			 fi
	  done
	  
	  cd $MSTEAM_PATH
	  for i in $(ls -1 *);
	  do
			 if [ -f $i ]
			 then
			 		FILES[a]=$MSTEAM_PATH/$i
					a=$(($a+1))
			 fi
	  done

	  cd $RESULT_PATH/PNGOut
	  for i in $(ls -1 *.gnpl *.dat);
	  do
			 if [ -f $i ]
			 then
			 		FILES[a]=$RESULT_PATH/PNGOut/$i
					a=$(($a+1))
			 fi
	  done


	  MSG='Copy all responsible files into directory '"$ARCHIVE_PATH"
	  LogMsg $STATUS "$MSG"
	  
	  cp ${FILES[*]} $ARCHIVE_PATH

	  cd $ARCHIVE_PATH

	  read -p 'Insert project name ' PROJECT_NAME

	  if [ -f arch_$PROJECT_NAME.tar.bz2 ]
	  then 
			 mv arch_$PROJECT_NAME.tar.bz2 arch_$PROJECT_NAME.tar.bz2.0
	  fi

  	  MSG="Archiving file arch_$PROJECT_NAME.tar.bz2"
	  LogMsg $STATUS "$MSG"
	  tar --create --bzip2 --remove-files --file arch_$PROJECT_NAME.tar.bz2 * >> $ACTUAL_DIR/$LOG_FILE
	  
	  cd $FINAL_PATH
	  
	  iter=0
	  defname=(arch_$PROJECT_NAME.tar.bz2)
	  name=$defname
#	  echo $name
	  while [ $iter != -1 ]
	  do
			 if [ -f $name ]
			 then
					iter=$(($iter+1))
					name=($defname.$iter)
#					echo $name
			 else
					iter=-1
			 fi
	  done	

	  mv $ARCHIVE_PATH/arch_$PROJECT_NAME.tar.bz2 $FINAL_PATH/$name

	  cd $ACTUAL_DIR
}


function CalcStart {
	  MSG="Steamgen starting"
	  LogMsg $STATUS "$MSG"

	  cd $STMG_PATH
	  
	  MSG="STEAMGEN START WITH DATA FILE "$STMG_CFG
	  echo $MSG
	  LogMsg $STATUS "$MSG"
	  $STMG_EXE $STMG_CFG
	  
	  MSG="Datafile for msteam generated ok"
	  LogMsg $STATUS "$MSG"

	  echo "STEAMGEN STOP"
	  
	  cd $MSTEAM_PATH

	  MSG="MSTEAM START CALCULATE"
	  echo $MSG
	  LogMsg $STATUS "$MSG"

	  RESULT_OUT="Result_output.out"

	  $MSTEAM_EXE < $MSTEAM_CFG > $MSTEAM_PATH/$RESULT_OUT

	  MSG="MSTEAM STOP CALCULATE"
	  echo $MSG
	  LogMsg $STATUS "$MSG"

	  for i in $(ls -1 *.plt *.log *.rst *.out inb* 2>>$ACTUAL_DIR/$LOG_FILE);
	  do
			 if [ -f $i ]
			 then
			 		FILES[a]=$i
					a=$(($a+1))
			 fi
	  done
	  
	  cp ${FILES[*]} $RESULT_PATH

#	  declare -a FILES
#	  a=0
#	  for i in $(ls -1 *.plt);
	  #	  do			 
#	  done
	  lines=$(grep -i -n 'STARTING THE MAIN TIME STEPPING LOOP' $MSTEAM_PATH/$RESULT_OUT | cut -d\: -f 1)
	  head -n $lines $MSTEAM_PATH/$RESULT_OUT
	  grep -i -n 'OVERALL POWER OUTPUT' $MSTEAM_PATH/$RESULT_OUT 2>>$ACTUAL_DIR/$LOG_FILE
  	  cd $ACTUAL_DIR
}

LogMsg $STATUS "SCRIPT steamgen_run.sh started"

case "$1" in
	  start) 
			 CfgRead
			 CalcStart
	  ;;
	  plot)
			 CfgRead
			 ./result_plot.sh start
			 echo $RESULT_PATH'/PNGOut/'
			 fl=$(ls -1 $RESULT_PATH/PNGOut/*POWER*.png  2>>$ACTUAL_DIR/$LOG_FILE)
			 eog "$fl" #OPEN WITH PROGRAM EYE OF GNOME
	  ;;
	  startPlot)
			 CfgRead
			 CalcStart
			 ./result_plot.sh start
			 fl=$(ls -1 $RESULT_PATH/PNGOut/*POWER*.png  2>>$ACTUAL_DIR/$LOG_FILE)
			 eog "$fl"  #OPEN WITH PROGRAM EYE OF GNOME
	  ;;
	  archive)
			 CfgRead
			 Archiving
	  ;;
	  archiveStart)
			 CfgRead
			 Archiving
			 CalcStart
	  ;;
	  archStartPlot)
			 CfgRead
			 Archiving
			 CalcStart
			 ./result_plot.sh start
	  ;;
	  *) echo 'UNKNOWN OPERATION! YOU MUST USE PARAMS START|PLOT|STARTPLOT|ACHIVE|ARCHIVESTART|ARCHSTARTPLOT'
esac	  
	  
LogEnd
