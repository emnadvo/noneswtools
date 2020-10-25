#!/bin/bash
#:
#: Title			: react_blade2D_projectprepare.sh
#: Date			: 16.11.2011 14:11:09
#: Version		: 1.0
#: Developer	: mnadvornik
#: Description	: Script for prepare directories for 2D calculations
#: Options		: 
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
declare LOGFORMAT="%s|%s| %s |%s\n"
declare DIVIDE="===================================\n"
declare ACTUAL_DIR=$(dirname $(readlink -f $0))
declare LOG_FILE=$ACTUAL_DIR/"react_blade2D_projectprepare.log"
declare STATUS="INFO"
declare MSG
declare TODAY=$(date '+%d.%m.%Y %H:%M:%S')
declare SCRIPTCFG=$ACTUAL_DIR/"react_blade2D_projectprepare.cfg"
declare -a SCRPROPERTY
declare ARRAYSIZE=0
declare DIRRIGHTS=777
declare MAXWORKID
declare PROFILEWDR

declare PROFILESDIR_ID=1
declare FINALDIR_ID=2
declare CALCTEMPDIR_ID=3

declare CFGEXT=".cfg"
declare TRBEXT=".trb"
declare BCEXT=".bc"
declare GEOMTURBOEXT=".geomTurbo"
declare IGGEXT=".igg"

declare MESHDIR="Meshes"
declare RESULTSDIR="Results"
declare INPUTSDIR="Inputs"
declare CASEPREPDIR="CasePrepare"
declare BCPREPDIR="BC"
declare PROFILENAMETEMP="%s_%s_%s"
declare NUMECAVERSION="90_3"
declare CFVIEW_SCRIPT="results_bind_ver4.py"
declare CFG_EXPORTCONST="[DEFAULT]\nSETTINGS_PATH=settings\nCALCMESH_DIR=calc_mesh\nNUMVERSION=$NUMECAVERSION\nNUMECALOCATE=/opt/sw/numeca/bin\nVINIT_VALUE=1\nCFVIEW_SCRIPT=$CFVIEW_SCRIPT\nPARALELING=1\n"
declare CFG_MESH="MESH_PATH=%s\n"
declare CFG_SOLVER="CALCDIR_NAME=%s\n"
declare CFG_BCDIR="BOUNDARYCOND_DIR=%s\n"
declare CFG_RESDIR="RESULTS_PATH=%s\n"

#declare FILESDIRECTORY="/windows/D/Dokumentace/Reports/React2D/cases/Prepare"
#declare FINALDESTDIR="/windows/D/Dokumentace/Reports/React2D/cases/Actual"

declare -a PROFILESARRAY
declare SUMOFPROFILESARRAY

declare -a REYNOARRAY
declare SUMOFREYNOARRAY

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
     #SCRIPTCFG=$(dirname $(readlink -f $0))/$SCRIPTCFG
	  if [ -f $SCRIPTCFG ] 
	  then	  
			 #MSG="READ DATA FROM CONFIG FILE START "$SCRIPTCFG
			 #LogMsg $STATUS "$MSG"
			 a=1
			 for line in `awk '$0 !~ /#.*/ {print $0}' $SCRIPTCFG 2>>$LOG_FILE`			 
			 do
					SCRPROPERTY[a]=$line
	  	  			let a++					
			 done

			 #LogMsg $STATUS "$MSG"
 			 ARRAYSIZE=${#SCRPROPERTY[*]}

			 MSG=("END READ SECTION FROM FILE "$SCRIPTCFG" - OK.\nREAD $ARRAYSIZE ITEMS.\n")
			 printf "$MSG"
	  fi
}

function get_profiles {
	  # function get all profiles in prepare directory
	  # @param1: directory with all files for profiles items
	  PROFILEDIR=${1:-"NONE"}
	  INDEXP=0
	  if [ -d $PROFILEDIR ]
	  then
			 for item in `find $PROFILEDIR -type f -regex '.*.geom.urbo' -printf "%P\n" | cut -d \. -f 1 | sort -u 2>>$LOG_FILE`
			 do
					PROFILESARRAY[INDEXP]=$item
					let INDEXP++
			 done
	  fi
	  SUMOFPROFILESARRAY=${#PROFILESARRAY[*]}
}


function get_maxProjectID {
	  #function for finding max value for calculation project
	  #@param1: directory with all projects
	  WORKDIR=${1:-"NONE"}
	  CWD=`pwd`
	  cd $WORKDIR
	  MAXWORKID=`find ./ -maxdepth 1 -type d -regex '.*20[0-9][0-9]_[0-9]+.*' -printf '%f\n' | sort | tail -n 1 | cut -d '_' -f 2 2>>$LOG_FILE`
	  if [[ -n "$MAXWORKID" && ${MAXWORKID:0:1} -eq 0 ]]; then
			 MAXWORKID=${MAXWORKID:1:2}
			 if [[ -n "$MAXWORKID" && ${MAXWORKID:0:1} -eq 0 ]]; then
					MAXWORKID=${MAXWORKID:1:2}
			 fi
	  fi
	  cd $CWD
}


function create_directories {
	  #function create directory for profile items
	  PROFILENAME=${1:-"NONE"}
	  if [ -d ${SCRPROPERTY[$FINALDIR_ID]} ]
	  then
			 mkdir --mode=$DIRRIGHTS ${SCRPROPERTY[$FINALDIR_ID]}/$PROFILENAME 2>>$LOG_FILE
			 mkdir --mode=$DIRRIGHTS ${SCRPROPERTY[$FINALDIR_ID]}/$PROFILENAME/$MESHDIR 2>>$LOG_FILE
			 mkdir --mode=$DIRRIGHTS ${SCRPROPERTY[$FINALDIR_ID]}/$PROFILENAME/$RESULTSDIR 2>>$LOG_FILE
			 mkdir --mode=$DIRRIGHTS ${SCRPROPERTY[$FINALDIR_ID]}/$PROFILENAME/$INPUTSDIR 2>>$LOG_FILE
	  fi
}


function move_files {
	  #function create directory for profile items
	  PROFILEID=${1:-""}
	  COPYDIR=${2:-""}

	  for item in `find ${SCRPROPERTY[$PROFILESDIR_ID]} -type f -name "$PROFILEID*"`
	  do
			 NEWNAME=$(expr "$item" : ".*\($PROFILEID.*\).*")
#			 mv --backup="numbered" $item $COPYDIR/$INPUTSDIR/$NEWNAME 2>>$LOG_FILE
#DEBUG
			 cp --backup="numbered" -p $item $COPYDIR/$INPUTSDIR/$NEWNAME 2>>$LOG_FILE
	  done
}


function get_Reyno_forProfile {
	  #function create directory for profile items	  
	  #@param1: Profile directory
	  PROFILEDIR=${1:-"NONE"}
	  unset REYNOARRAY
	  INDEXR=0
	  BCFILE=`find $PROFILEDIR/$INPUTSDIR -type f -name "*$BCEXT"`
	  GEOMTURBOFILE=`find $PROFILEDIR/$INPUTSDIR -type f -iname "*$GEOMTURBOEXT"`
	  if [ "${#BCFILE[*]}" -eq 1 ]
	  then
			 for reyno in `awk '$1 !~ /[a-z]/ {print $2}' "$BCFILE" | sort -u`
			 do
					#echo $reyno
					REYNOARRAY[INDEXR]=$reyno
					let INDEXR++					
			 done
	  fi
}
###############################################################################################
# MAIN ACTION PART
###############################################################################################

#debug flag start
#set -x

#debug flag stop
#set +x

# Read configuration data from cfg file
if [ -f $SCRIPTCFG ]
then
	  CfgRead
else
	  msg="YOUR CONFIGURATION FILE $SCRIPTCFG IS INVALID!\n"
	  printf "$msg"
	  exit 1
fi

#echo ${SCRPROPERTY[*]}

# When array with all properties was set, get profiles item
if [ $ARRAYSIZE -ge $FINALDIR_ID ]
then
	  get_profiles "${SCRPROPERTY[$PROFILESDIR_ID]}"
fi

#Get last value from project directory
if [ -d ${SCRPROPERTY[$FINALDIR_ID]} ]
then
	  get_maxProjectID "${SCRPROPERTY[$FINALDIR_ID]}"
fi

PROJID=${MAXWORKID:-0}
let PROJID++
YEAR=`date '+%Y'`

# Profiles parsed. Create directory and moves files to final destinations.
if [[ $SUMOFPROFILESARRAY -ge 1 ]]
then
	  # For profile prepare boundary conditions and mesh directory
	  for profile in "${PROFILESARRAY[@]}"
	  do
			 #append 0 when PROJID less then 100 - required format e.g. 025
			 if [ $PROJID -lt 100 ]; then
					if [ ${#PROJID} -eq 1 ]; then
						  NEWPROJID=00$PROJID		 
					elif [ ${#PROJID} -eq 2 ]; then
						  NEWPROJID=0$PROJID
					fi
			 else
					NEWPROJID=$PROJID
			 fi
			 	
			 PROFILEWDR=`printf "$PROFILENAMETEMP" "$YEAR" "$NEWPROJID" "$profile"`

			 create_directories "$PROFILEWDR"

			 move_files "$profile" "${SCRPROPERTY[$FINALDIR_ID]}/$PROFILEWDR"

			 get_Reyno_forProfile "${SCRPROPERTY[$FINALDIR_ID]}/$PROFILEWDR"

			 # For profile and Reynolds numbers create directories in boundary and mesh directories
			 #CREATE DIRECTORY for meshes placing
			 if [ -d ${SCRPROPERTY[$FINALDIR_ID]}/$PROFILEWDR/$MESHDIR ]
			 then
					cp --backup="numbered" -p $GEOMTURBOFILE ${SCRPROPERTY[$FINALDIR_ID]}/$PROFILEWDR/$MESHDIR/$profile$GEOMTURBOEXT 
			 else
					msg="DIRECTORY FOR BOUNDARY CONDITION (${SCRPROPERTY[$FINALDIR_ID]}/$PROFILEWDR/$MESHDIR) IS INVALID!\n"			 
					printf "$msg"
					exit 1
			 fi

			 #CREATE DIRECTORY for numeca calculation prepare
			 SOLDEFPROFILE_DIR=${SCRPROPERTY[$FINALDIR_ID]}/$PROFILEWDR/$INPUTSDIR/$CASEPREPDIR
			 BOUNDARYCND_DIR=${SCRPROPERTY[$FINALDIR_ID]}/$PROFILEWDR/$INPUTSDIR/$BCPREPDIR
			 		 
			 if [ -d ${SCRPROPERTY[$FINALDIR_ID]}/$PROFILEWDR/$INPUTSDIR ]
			 then
					#create directory Inputs/CasePrepare
					mkdir --mode=$DIRRIGHTS $SOLDEFPROFILE_DIR 2>>$LOG_FILE
					
					#directory boundary_conditions
					mkdir --mode=$DIRRIGHTS $BOUNDARYCND_DIR 2>>$LOG_FILE
			 else
					msg="DIRECTORY FOR SOLVER DEFINITION (${SCRPROPERTY[$FINALDIR_ID]}/$PROFILEWDR/$INPUTSDIR) IS INVALID!\n"
					printf "$msg"
					exit 1
			 fi

			 #CREATE DIRECTORY ./settings/calc_mesh/solver_def/PROFILE/Re00100e3
			 for REYNO in "${REYNOARRAY[@]}"
			 do
					#directory solver_def
					REYNODIR="Re"$REYNO
					DIRFIND=
					#copy template for Reynolds number from template dir cfg_id=3
					TEMPLCASEDIR=${SCRPROPERTY[$CALCTEMPDIR_ID]:-""}/$REYNODIR
					if [ -d $TEMPLCASEDIR ]
					then
						  cp -pr $TEMPLCASEDIR $SOLDEFPROFILE_DIR 2>>$LOG_FILE
					else
						  mkdir -p --mode=$DIRRIGHTS $SOLDEFPROFILE_DIR/$REYNODIR 2>>$LOG_FILE
					fi

					if [ -d $BOUNDARYCND_DIR ]
					then
						  #directories boundary conditions
						  mkdir --mode=$DIRRIGHTS $BOUNDARYCND_DIR/$REYNODIR 2>>$LOG_FILE

						  #create boundary conditions for Reynolds number
						  head -n 1 $BCFILE > $BOUNDARYCND_DIR/$REYNODIR/$profile$BCEXT
						  awk '$2 == '$REYNO' {print $0}' $BCFILE >> $BOUNDARYCND_DIR/$REYNODIR/$profile$BCEXT 2>>$LOG_FILE
		
						  CFGFILE=$BOUNDARYCND_DIR/$profile
						  #create config file for profile cases
						  printf "$CFG_EXPORTCONST" > $CFGFILE"_"$REYNODIR$CFGEXT 2>>$LOG_FILE
						  #export solver def
						  DIRFIND=`find $SOLDEFPROFILE_DIR/$REYNODIR -type f -name '*.run'`
						  if [ -n "$DIRFIND" ]
						  then
								 DIRFIND=`dirname $DIRFIND`
						  else
								 DIRFIND=$SOLDEFPROFILE_DIR/$REYNODIR
						  fi

						  printf "$CFG_SOLVER" "$DIRFIND" >> $CFGFILE"_"$REYNODIR$CFGEXT 2>>$LOG_FILE

						  #export boundary condition
						  printf "$CFG_BCDIR" "$BOUNDARYCND_DIR/$REYNODIR" >> $CFGFILE"_"$REYNODIR$CFGEXT 2>>$LOG_FILE
						  #export mesh path
						  touch ${SCRPROPERTY[$FINALDIR_ID]}/$PROFILEWDR/$MESHDIR/$profile"_"$REYNODIR$TRBEXT 2>>$LOG_FILE
						  printf "$CFG_MESH" "${SCRPROPERTY[$FINALDIR_ID]}/$PROFILEWDR/$MESHDIR/$profile"_"$REYNODIR$IGGEXT" >> $CFGFILE"_"$REYNODIR$CFGEXT 2>>$LOG_FILE
						  #export resultdir
						  printf "$CFG_RESDIR" "${SCRPROPERTY[$FINALDIR_ID]}/$PROFILENAME/$RESULTSDIR" >> $CFGFILE"_"$REYNODIR$CFGEXT 2>>$LOG_FILE					
					fi
			 done

			 echo "PROFILE $profile WAS PREPARED CORRECT FOR NEXT PROCESSING."
			 let PROJID++
	  done
fi

wait ${!}
#LogEnd
exit 0
