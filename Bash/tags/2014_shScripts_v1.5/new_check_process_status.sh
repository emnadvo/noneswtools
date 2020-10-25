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
declare LOG_FILE=$ACTUAL_DIR/"new_check_process_status.log"
declare STATUS="INFO"
declare MSG
declare TODAY=$(date '+%d.%m.%Y %H:%M:%S')
declare RESULT
declare PROCSTAT
declare STATE
declare RETEST


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

RETEST=0
PROCID=$1

if [ -z "$1" ]
 then
	  msg='Need input parameter which is command name of checked process or pid of checked process'
	  echo $msg
	  LogMsg $STATUS "Script failed! $msg"
	  exit 2
fi

if [ -n "$2" ]
then
	  LOG_FILE=$2
fi

LogMsg $STATUS "------ SCRIPT check_process_status START ------"
LogMsg $STATUS "System check process with id: $1"

#check if process with input pid exist
proces_exist=$(ps -A -l | grep $PROCID 2>>$LOG_FILE)
if [ -z "$proces_exist" ]
 then
	  echo 'NOTEXIST'
	  LogEnd
	  exit 0
	
else	#process exist - check it
	# find running processe with pid
	  #set -x
	  stat=$( ps -A -l | grep $PROCID | awk '{print $2}' )
	  if [ `expr index "$stat" 'R'` -gt 0 ]
	   then
			 STATE='RUN'
	  fi

	# any processes running
	# then check if subprocess not sleep
	if [ -z "$STATE" ]
	then
		  #test if process not sleep
		  for ppid in $( ps -A -o '|%p|%P' | grep $PROCID |  cut -d '|' -f 2 )
		    do
					if [ $ppid -ne $PROCID ] 
					 then
						  msg="EXIST SUBPROCES WITH PID $ppid\nIT CHECK START"
						  LogMsg $STATUS "$msg"
						  for i in 1 2 3 4 5
						  do
								 stat=$( ps -Al | grep $ppid'[\ ]*'$PROCID | cut -d ' ' -f 2 )
								 if [ -n "$stat" ] && [ "$stat" == 'S' ]
								  then
										RETEST=$(($RETEST+1))
										stat=''
										sleep 11
								 fi
						  done
						  
						  if [ $RETEST -ge 5 ]
						   then
								 msg="PROCES WITH PID $ppid WAS RETURNED CONTROL BECAUSE IT LOOKS LIKE RESTING PROCESS"
								 LogMsg $STATUS "$msg"
								 #process sleep -> terminate
								 #retval=`kill -s SIGTERM $ppid 2>&1`
								 FINALSTATE='ZOMBIE'
								 sleep 10 
								 if [ -n "$retval" ] 
								  then
									  echo $retval >> $LOG_FILE
								fi
						  fi
						  msg="SUBPROCES WITH PID $ppid CHECKED END"
						  LogMsg $STATUS "$msg"
					fi
		  done
		  
		  if [ -z "$FINALSTATE" ]
		   then
				 CheckProc $PROCID
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
		  fi
			 
	else
		  FINALSTATE='RUN'
	fi
fi

if [ -n "$FINALSTATE" ]
 then
	  echo $FINALSTATE
fi

#set +x

LogEnd
exit $?
