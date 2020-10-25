#!/bin/bash
#:
#: Title			: check_process_status.sh
#: Date			: 18.05.2011 10:33:57
#: Version		: 1.0
#: Developer	: mnadvornik
#: Description	: Script for checking process status
#: Options		: 
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
declare LOGFORMAT="%s|%s| %s |%s\n"
declare DIVIDE="===================================\n"
declare ACTUAL_DIR=$(pwd)
declare LOG_FILE=$ACTUAL_DIR/"check_process_status.log"
declare STATUS="INFO"
declare MSG
declare TODAY=$(date '+%d.%m.%Y %H:%M:%S')
#declare SCRIPTCFG="$HOME/Data/check_process_status.cfg"
#declare -a SCRPROPERTY
#declare ARRAYSIZE=0
declare LNPID=4
declare RESULT
declare PROCSTAT
declare RET
declare LENRET
declare PIDCNT
declare PIDID
declare PID


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

function CheckProc {
	  PROCSTAT=$(less /proc/$1/status | grep 'State' | cut -d ':' -f 2) 2>>$LOG_FILE
	  LogMsg $STATUS "Proces with pid $1 have status: $PROCSTAT"
}
###############################################################################################
# MAIN ACTION PART
###############################################################################################

LogMsg $STATUS "------ SCRIPT check_process_status START ------"

PROCID=$1

if [ -z "$@" ]
 then
	  msg='Need input parameter which is command name of checked process or pid of checked process'
	  echo $msg
	  LogMsg $STATUS "Script failed! $msg"
	  exit 2
fi

LogMsg $STATUS "System check process with id: $1"
# Zkusim zda-li je vstupni parametr pid
if [ -d "/proc/$1" ]
 then
	  # kontrola na pid
	  CheckProc $1
else
	  # otestuji zda-li vstupni parametr neni nazev prikazu
	  RET=$(ps -A | grep $PROCID | cut -d ' ' -f 1) 2>>$LOG_FILE
	  LENRET=${#RET}
	  # test na delku nalezenych PIDu
	  if [ $LENRET -gt 0 ]
	   then
			 if [ $LENRET -gt $LNPID ]
			  then
					let "PIDCNT=$LENRET/$LNPID"
			 else
					PIDCNT=1
			 fi

			 PIDID=1
			 until [ $PIDID -gt $PIDCNT ]
			  do 
					PID=$(echo $RET | cut -d ' ' -f $PIDID)
					PIDID=$(($PIDID+1))

					CheckProc $PID
			 
					case $PROCSTAT in
					 *zombie*)
						  RESULT=$RESULT'ZOMBIE '
						  ;;
					 *running*)
						  RESULT=$RESULT'RUN '
						  ;;
					 *sleeping*)
						  RESULT=$RESULT'SLEEP '
						  ;;
					 badpid)
						  RESULT=$RESULT'BADPID '
						  ;;
					 *)
						  RESULT=$RESULT'UNKNOWN '
						  ;;
					esac

			 done
			 PROCSTAT=$RESULT
	  else
			 PROCSTAT='notexist'
	  fi
fi


case $PROCSTAT in
 *zombie*)
	  echo 'ZOMBIE'
	  ;;
 *running*)
	  echo 'RUN'
	  ;;
 *sleeping*)
	  echo 'SLEEP'
	  ;;
 notexist)
	  echo 'NOTEXIST'
	  ;;
 *)
	  echo $PROCSTAT
	  ;;
esac

LogEnd

exit $?
