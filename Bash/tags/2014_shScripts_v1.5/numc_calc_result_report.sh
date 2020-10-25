#!/bin/bash
#:
#: Title			: numc_calc_result_report.sh
#: Date			: 07.06.2011 09:11:51
#: Version		: 1.6
#: Developer	: mnadvornik
#: Description	: Script for create report from calculations.
#: Options		: 
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
declare LOGFORMAT="%s|%s| %s |%s\n"
declare DIVIDE="===================================\n"
declare ACTUAL_DIR=$(pwd)
declare LOG_FILE=$ACTUAL_DIR/"numc_calc_result_report.log"
declare STATUS="INFO"
declare MSG
declare TODAY=$(date '+%d.%m.%Y %H:%M:%S')
declare SCRIPTCFG="$HOME/Data/numc_calc_result_report.cfg"
declare -a SCRPROPERTY
declare ARRAYSIZE=0
declare FIRSTLINE="%s"
declare SECLINE="\t%s"
declare CSVLINE=";%s"
declare OUTPUT
declare CSVOUTPUT
declare HEADER
declare CSVHEADER
declare HEADLINES=105
declare TAILLINES=105

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
 			 ARRAYSIZE=$(($a-1))
	  fi
}

#Function for return format string
function GetHeadSecColumn {
	  TMP=`head -n $HEADLINES $1 | grep -w "$2" | awk '{ print $2}'`
	  CSVOUT=${TMP/./,}
}

#Function for return format string
function GetHeadThreeColumn {
	  TMP=`head -n $HEADLINES $1 | grep -w "$2" | awk '{ print $3}'`
	  CSVOUT=${TMP/./,}
}

#Function for return format string
function GetTailSecColumn {
	  TMP=`tail -n $TAILLINES $1 | grep -w "$2" | awk '{ print $2}'`
	  CSVOUT=${TMP/./,}
}

#Function for return format string
function GetTailThreeColumn {
	  TMP=`tail -n $TAILLINES $1 | grep -w "$2" | awk '{ print $3}'`
	  CSVOUT=${TMP/./,}
}

function AddColumnName {
	 HEADER+=`printf "\t%s" $1`
	 CSVHEADER+=`printf ";%s" $1`
}

function AppendHeadData {
	  if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	  then
			 case "$3" in
			  *IN*)
					GetHeadSecColumn "$1" "$2"
					;;
			  *OUT*)
					GetHeadThreeColumn "$1" "$2"
					;;
			  *)
					echo "unknonw section for data binding"
					;;
			 esac
	  
			 if [ -n "$TMP" ]
			  then
					OUTPUT+=`printf $SECLINE "$TMP"`
			 else
					OUTPUT+=`printf $SECLINE "-"`
			 fi

			 if [ -n "$CSVOUT" ]
			  then
					CSVOUTPUT+=`printf $CSVLINE "$CSVOUT"`
			 else
					CSVOUTPUT+=`printf $CSVLINE "-"`
			 fi
	  else
			 echo "Need input parameter into function AppendData"
	  fi
}

function AppendTailData {
	  if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	  then
			 case "$3" in
			  *IN*)
					GetTailSecColumn "$1" "$2"
					;;
			  *OUT*)
					GetTailThreeColumn "$1" "$2"
					;;
			  *)
					echo "unknonw section for data binding"
					;;
			 esac
	  
			 if [ -n "$TMP" ]
			  then
					OUTPUT+=`printf $SECLINE "$TMP"`
			 else
					OUTPUT+=`printf $SECLINE "-"`
			 fi

			 if [ -n "$CSVOUT" ]
			  then
					CSVOUTPUT+=`printf $CSVLINE "$CSVOUT"`
			 else
					CSVOUTPUT+=`printf $CSVLINE "-"`
			 fi
	  else
			 echo "Need input parameter into function AppendData"
	  fi
}

###############################################################################################
# MAIN ACTION PART
###############################################################################################

#LogMsg $STATUS "------ SCRIPT numc_calc_result_report STARTED ------"

#CfgRead

CSVFILENAME=$ACTUAL_DIR/"calc_result_report.csv"
RESFILENAME=$ACTUAL_DIR/"calc_result_report.out"

if [ -z "$@" ]
 then
	  echo 'Script need input parameters!'
	  echo 'P1= working directory.'
	  exit 0
fi

if [ -d $1 ]
 then	  
	  echo 'START PROCESSING'
	  a=0
	  for item in `find $1 -type f -name '*[\.]mf'`
	  do
			 COL_NAME="RESULT_FILE"
			 HEADER=`printf $FIRSTLINE "$COL_NAME"`
			 CSVHEADER=`printf "%s" $COL_NAME`
			 RESNAME=`echo ${item##*/}|cut -d '.' -f 1`
			 OUTPUT=`printf $FIRSTLINE "$RESNAME"`
			 CSVOUTPUT=`printf "%s" "$RESNAME"`

			 echo "EXECUTE FILE $RESNAME"

			 AddColumnName "NODES"
			 AppendHeadData "$item" "Total_number_of_nodes" "IN"

			 AddColumnName "Cp"
			 AppendHeadData "$item" "Specific_heat.(Cp)" "OUT"

			 AddColumnName "KAPPA"
			 AppendHeadData "$item" "Specific_heat_ratio" "IN"

			 AddColumnName "MASSFLOW_IN"
			 AppendHeadData "$item" "Absolute_Mass_flow" "IN"

			 AddColumnName "MASSFLOW_OUT"
			 AppendHeadData "$item" "Absolute_Mass_flow" "OUT"

			 AddColumnName "RAD_SPEED_IN"
			 AppendHeadData "$item" "Radial_velocity" "IN"

			 AddColumnName "RAD_SPEED_OUT"
			 AppendHeadData "$item" "Radial_velocity" "OUT"

			 AddColumnName "AX_SPEED_IN"
			 AppendHeadData "$item" "Axial_velocity" "IN"

			 AddColumnName "AX_SPEED_OUT"
			 AppendHeadData "$item" "Axial_velocity" "OUT"

			 AddColumnName "ABS_TAN_SPEED_IN"
			 AppendHeadData "$item" "Absolute_tangential_velocity" "IN"

			 AddColumnName "ABS_TAN_SPEED_OUT"
			 AppendHeadData "$item" "Absolute_tangential_velocity" "OUT"

			 AddColumnName "ABS_SPEED_MAGNITUDE_IN"
			 AppendHeadData "$item" "Absolute_velocity_magnitude" "IN"

			 AddColumnName "ABS_SPEED_MAGNITUDE_OUT"
			 AppendHeadData "$item" "Absolute_velocity_magnitude" "OUT"

			 AddColumnName "ABS_MACH_IN"
			 AppendHeadData "$item" "Absolute_Mach_number" "IN"

			 AddColumnName "ABS_MACH_OUT"
			 AppendHeadData "$item" "Absolute_Mach_number" "OUT"

			 AddColumnName "DENSITY_IN"
			 AppendHeadData "$item" "Density" "IN"

			 AddColumnName "DENSITY_OUT"
			 AppendHeadData "$item" "Density" "OUT"

			 AddColumnName "STAT_PRESS_IN"
			 AppendHeadData "$item" "Static_pressure" "IN"

			 AddColumnName "STAT_PRESS_OUT"
			 AppendHeadData "$item" "Static_pressure" "OUT"

			 AddColumnName "STAT_TEMP_IN"
			 AppendHeadData "$item" "Static_temperature" "IN"

			 AddColumnName "STAT_TEMP_OUT"
			 AppendHeadData "$item" "Static_temperature" "OUT"

			 AddColumnName "ABS_TOT_PRESS_IN"
			 AppendHeadData "$item" "Absolute_total_pressure" "IN"

			 AddColumnName "ABS_TOT_PRESS_OUT"
			 AppendHeadData "$item" "Absolute_total_pressure" "OUT"

			 AddColumnName "ABS_TOT_TEMP_IN"
			 AppendHeadData "$item" "Absolute_total_temperature" "IN"

			 AddColumnName "ABS_TOT_TEMP_OUT"
			 AppendHeadData "$item" "Absolute_total_temperature" "OUT"

			 AddColumnName "ISENTROPIC_EFFICIENCY"
			 AppendHeadData "$item" "Isentropic_efficiency" "IN"

			 AddColumnName "POLYTROPIC_EFFICIENCY"
			 AppendHeadData "$item" "Polytropic_efficiency" "IN"

			 AddColumnName "TORQUE"
			 AppendHeadData "$item" "Torque" "IN"

			 AddColumnName "POWER"
			 AppendHeadData "$item" "Power" "IN"

			 AddColumnName "HUB_RADIUS_IN"
			 AppendHeadData "$item" "Hub_radius" "IN"

			 AddColumnName "HUB_RADIUS_OUT"
			 AppendHeadData "$item" "Hub_radius" "OUT"

			 AddColumnName "SHROUD_RADIUS_IN"
			 AppendHeadData "$item" "Shroud_radius" "IN"

			 AddColumnName "SHROUD_RADIUS_OUT"
			 AppendHeadData "$item" "Shroud_radius" "OUT"

			 AddColumnName "NUM_BLADES_IN"
			 AppendHeadData "$item" "Number_of_blades" "IN"

			 AddColumnName "NUM_BLADES_OUT"
			 AppendHeadData "$item" "Number_of_blades" "OUT"

			 if [ $a -eq 0 ]
			 then
					echo $HEADER > $RESFILENAME
					printf "%s\n" $CSVHEADER > $CSVFILENAME
			 fi

			 a=$(($a+1))

			 if [ -f $RESFILENAME ]
			 then
					printf "%s\n" "$OUTPUT" >> $RESFILENAME
			 else
					printf "%s\n" "$OUTPUT" > $RESFILENAME
			 fi

			 
			 if [ -f $CSVFILENAME ]
			 then
					printf "%s\n" "$CSVOUTPUT" >> $CSVFILENAME
			 else
					printf "%s\n" "$CSVOUTPUT" > $CSVFILENAME
			 fi

	  done
fi 

echo 'FINISHED'

#LogEnd
