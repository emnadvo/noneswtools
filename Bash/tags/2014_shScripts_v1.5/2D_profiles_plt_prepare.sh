#!/bin/bash
#:
#: Title			: 2D_profiles_plt_prepare.sh
#: Date			: 04.11.2011 09:28:54
#: Version		: 1.0
#: Developer	: mnadvornik
#: Description	: Script for prepare plot commands for gnuplot.
#: Options		: 
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
declare LOGFORMAT="%s|%s| %s |%s\n"
declare DIVIDE="===================================\n"
declare ACTUAL_DIR=$(pwd)
declare LOG_FILE=$ACTUAL_DIR/"2D_profiles_plt_prepare.log"
declare STATUS="INFO"
declare MSG
declare TODAY=$(date '+%d.%m.%Y %H:%M:%S')
#declare SCRIPTCFG="$HOME/Data/2D_profiles_plt_prepare.cfg"
declare -a SCRPROPERTY
declare ARRAYSIZE=0
declare FILENAME='_gnplt.plt'
declare AVGRESULTS='_aver.res'
declare SURFRESULTS='.surf'
declare RESEXTENS='.res'
declare DIRRIGHTS=777

#declare FONTTERM="\"/usr/share/fonts/truetype/ttf-dejavu/DejaVuSerif.ttf\" 14"
#declare FONTTITLE="\"/usr/share/fonts/truetype/ttf-dejavu/DejaVuSans.ttf,18\""

declare FONTTERM="\"dejavuserif\" 14"
declare FONTTITLE="\"gorgia,18\""

#export GDFONTPATH="/usr/share/fonts/truetype/ttf-dejavu/DejaVuSerif.ttf"

#Gnuplot templates
declare GNPL_FLOAT_FORMAT_0="%.0f"
declare GNPL_FLOAT_FORMAT_1="%.1f"
declare GNPL_FLOAT_FORMAT_2="%.2f"
declare GNPL_FLOAT_FORMAT_3="%.3f"
declare GNPL_FLOAT_FORMAT_4="%.4f"
declare GNPL_FLOAT_FORMAT_6="%.6f"
declare GNPL_FLOAT_FORMAT_8="%.8f"
declare GNPL_EXPO_FORMAT="%e"
declare GNPL_INDEX_MIN=0
declare GNPL_INDEX_MAX=92

declare GNPL_NEWLINE="\n"
declare GNPL_FILETMPL=$ACTUAL_DIR/"2D_graph_plt_template.tmpl"
declare GNPL_TITLE_TMPL="set title \"%s\" font $FONTTITLE \n"
declare GNPL_RANGE_TMPL="range_%d"
declare GNPL_USING_TMPL="using "
declare GNPL_STYLE_TMPL="style_%d"
declare GNPL_RANGESTYLE_LINE="%s=\"%s\"\n"

declare GNPL_XFORMAT="set format x \"%s\"\n"
declare GNPL_xLABEL="set xlabel \"%s\" offset \"45, 0\"\n"

declare GNPL_YFORMAT="set format y \"%s\"\n"
declare GNPL_YLABEL="set ylabel \"%s\" offset \"0, 15\"\n"

declare GNPL_TERMINAL_TOX_TMPL="set terminal %s\n"
declare GNPL_TERMINAL_TOPICT_TMPL="set terminal %s %s size %d,%d\n"
declare GNPL_OUTPUT_TMPL="set output \"%s.%s\"\n"
declare GNPL_OUTPUT_CONST_X11="set output\n"

declare GRAPHSDIR_TEMPL="/graphs/"
declare GRAPHSDIR
declare RESULTDIR
declare CALCCASE
declare BLADENAME
declare ACTUALPLOTSCRIPT
declare OUTPUT_LINE

declare -a ARRAYOFREYNOLDS
declare SUMARRAYOFREYNOLDS
declare -a ARRAYOFMACHS
declare SUMARRAYOFMACHS
declare ARRAYINDEX=0

declare GRAPHEXT="png"
declare id_x=1
declare id_absP=2
declare id_absT=3
declare id_statP=5
declare id_statT=6
declare id_Mach=10
declare id_absV=9
declare id_Dzeta=13
declare id_DzetaY=14
declare id_massflow=16
declare id_angle=12
declare id_entrophy=15
declare id_izomach=3
declare id_surf_statP=4
declare id_surfCp=5

declare pascal=" [Pa]"
declare kelvin=" [K]"
declare speed=" [m/s]"
declare angle=" [deg]"
declare one=" [1]"
declare massflow=" [kg/s]"
declare entrophy=" [J/(kg.K)]"

#Function for logging any messages
function LogMsg {
	  TODAY=$(date '+%d.%m.%Y %H:%M:%S')	  
	  if [ ! -f $LOG_FILE ]
	  then
			 LINE=`printf "$LOGFORMAT" "$TODAY" "$USER" "$1" "$2"`
			 #echo $LINE
			 echo $LINE > $LOG_FILE
	  else
			 LINE=`printf "$LOGFORMAT" "$TODAY" "$USER" "$1" "$2"`
			 #echo $LINE
			 echo $LINE >> $LOG_FILE
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

#Function for create block of gnuplot graph command for physical property
function Create2DGraph {
	  # @param 1: Title of graph
	  # @param 2: Property for axe-x  (X[mm])
	  # @param 3: Property for axe-y	(AbsP [Pa])
	  # @param 4: ID of property on x axe for using clause
	  # @param 5: ID of property on x axe for using clause
	  # @param 6: Title of line
	  # @param 7: Style of line
	  # @param 8: Plot file to output
	  # @param 9: Data source
	  # @param 10: Name for output
	  
	  FULLNAME=${1:-"Unknown Property"}
	  NAME_X=${2:-"Unknown Property"}
	  NAME_Y=${3:-"Unknown Property"}
	  ID_X=${4:-"Unknown Property"}
	  ID_Y=${5:-"Unknown Property"}
	  LINETITLE=${6:-"notitle"}
	  LINESTYLE=${7:-"Unknown Property"}
	  OUTPUTFILE=${8:-"Unknown Property"}
	  DATASOURCE=${9:-"Unknown Property"}
	  SHORTNAME=${10:-"Unknown Property"}


	  #set label
	  printf "$GNPL_TITLE_TMPL" "$FULLNAME" >>$OUTPUTFILE 
	  #set xlabel
	  printf "$GNPL_xLABEL" "$NAME_X" >>$OUTPUTFILE 
	  #set ylabel
	  printf "$GNPL_YLABEL" "$NAME_Y" >>$OUTPUTFILE

	  #style_1="ls 2"
	  STYLE=$(printf "$GNPL_STYLE_TMPL" "1")
	  printf "$GNPL_RANGESTYLE_LINE" "$STYLE" "$LINESTYLE" >>$OUTPUTFILE
	  STYLE="@$STYLE"

	  #range_1="using 2:4"
	  RANGE=$(printf "$GNPL_RANGE_TMPL" "1")
	  USING=$(printf "$GNPL_USING_TMPL $4:$5")
	  printf "$GNPL_RANGESTYLE_LINE" "$RANGE" "$USING" >>$OUTPUTFILE
	  RANGE="@$RANGE"

	  if [ "$LINETITLE" != "notitle" ]
	  then
			 TITLE="title \'$LINETITLE\'"
	  else
			 TITLE="notitle"
	  fi

	  #set output "nazev.png"
	  printf "$GNPL_OUTPUT_TMPL"  "$SHORTNAME" "$GRAPHEXT">>$OUTPUTFILE
	  
	  printf "plot \'%s\' $RANGE $STYLE $TITLE\n" "$DATASOURCE" >>$OUTPUTFILE

	  printf "$GNPL_NEWLINE" >>$OUTPUTFILE
} 


function Create2DGraph_nProp {
	  # @param 1: Title of graph
	  # @param 2: Property for axe-x  (X[mm])
	  # @param 3: Property for axe-y	(AbsP [Pa])
	  # @param 4: ID of property on x axe for using clause
	  # @param 5: ID of property on x axe for using clause
	  # @param 6: Title of line
	  # @param 7: Style of line
	  # @param 8: Plot file to output
	  # @param 8: Plot file to output
	  # @param 9: Data source
	  # @param 10: Name for output
	  
	  FULLNAME=${1:-"Unknown Property"}
	  NAME_X=${2:-"Unknown Property"}
	  NAME_Y=${3:-"Unknown Property"}
	  ID_X=${4:-"Unknown Property"}
	  ID_Y=${5:-"Unknown Property"}
	  LINETITLE=${6:-"notitle"}
	  LINESTYLE=${7:-"Unknown Property"}
	  OUTPUTFILE=${8:-"Unknown Property"}
	  DATASOURCE=${9:-"Unknown Property"}
	  SHORTNAME=${10:-"Unknown Property"}


	  #set label
	  printf "$GNPL_TITLE_TMPL" "$FULLNAME" >>$OUTPUTFILE 
	  #set xlabel
	  printf "$GNPL_xLABEL" "$NAME_X" >>$OUTPUTFILE 
	  #set ylabel
	  printf "$GNPL_YLABEL" "$NAME_Y" >>$OUTPUTFILE

	  #style_1="ls 2"
	  STYLE=$(printf "$GNPL_STYLE_TMPL" "1")
	  printf "$GNPL_RANGESTYLE_LINE" "$STYLE" "$LINESTYLE" >>$OUTPUTFILE
	  STYLE="@$STYLE"

	  #range_1="using 2:4"
	  RANGE=$(printf "$GNPL_RANGE_TMPL" "1")
	  USING=$(printf "$GNPL_USING_TMPL $4:$5")
	  printf "$GNPL_RANGESTYLE_LINE" "$RANGE" "$USING" >>$OUTPUTFILE
	  RANGE="@$RANGE"

	  #set output "nazev.png"
	  printf "$GNPL_OUTPUT_TMPL"  "$SHORTNAME" "$GRAPHEXT">>$OUTPUTFILE
	  
	  printf "plot \'%s\' $RANGE $STYLE $LINETITLE\n" "$DATASOURCE" >>$OUTPUTFILE

	  printf "$GNPL_NEWLINE" >>$OUTPUTFILE
}



function test_inputs { 
	  #tests your inputs
	  #@param1 directory with results

	  if [ -z "$@" ]
	  then
			 msg='NEED INPUT PARAMETER WHICH IS DIRECTORY WITH A RESULTS!'
			 echo $msg
			 echo 'INSERT PATH OF DIRECTORY WITH RESULTS'
			 read RESULTDIR
	  else
			 RESULTDIR="${1:-""}"
	  fi
}

function plot_2Dgraphs_from_calc { 
	  #generate block with 2D graphs for all interesting property for every calculations 
	  #@param1 Reynolds numbers of calculation
	  #@param2 Mach numbers of calculation
	  #@param3 Directory for graph export

	  REYNOLDS=${1:-"Unknown Property"}
	  MACHNUMB=${2:-"Unknown Property"}
	  RESDIRECTOR=${3:-"Unknown Property"}


	  #najdu si pouze pro jednotlive Reynoldsovy cisla a jednotlive Machova cisla -> vytvorim grafy
	  for item in `find $RESULTDIR -type f -name "$REYNOLDS*$MACHNUMB*$AVGRESULTS" 2>>$LOG_FILE`
	  do					
			 #set format x "0.4f"
			 printf "$GNPL_XFORMAT" "$GNPL_FLOAT_FORMAT_2" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 LINESPOINTS_LW2_RED="with linespoints lt 1.8 lw 5"

			 OUTPUT_LINE=$RESDIRECTOR"absolute_temp"
			 Create2DGraph "Absolute Temperature" "X [mm]" "Total Temperature$kelvin"\
			 "$id_x" "$id_absT" "non" "$LINESPOINTS_LW2_RED" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE" 

			 OUTPUT_LINE=$RESDIRECTOR"absolute_press"
			 Create2DGraph "Absolute Press" "X [mm]" "Total Press$pascal"\
			 "$id_x" "$id_absP" "non" "$LINESPOINTS_LW2_RED" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE" 

			 OUTPUT_LINE=$RESDIRECTOR"static_press"
			 PROP_NAME="Static Press"
			 Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$pascal"\
			 "$id_x" "$id_statP" "non" "$LINESPOINTS_LW2_RED" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE" 

			 OUTPUT_LINE=$RESDIRECTOR"static_temperature"
			 PROP_NAME="Static Temperature"
			 Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$kelvin"\
			 "$id_x" "$id_statT" "non" "$LINESPOINTS_LW2_RED" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE" 

			 OUTPUT_LINE=$RESDIRECTOR"mach_number"
			 PROP_NAME="Mach Number"
			 Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$one"\
			 "$id_x" "$id_Mach" "non" "$LINESPOINTS_LW2_RED" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE" 

			 OUTPUT_LINE=$RESDIRECTOR"velocity_magnitude"
			 PROP_NAME="Velocity Magnitude"
			 Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$speed"\
			 "$id_x" "$id_absV" "non" "$LINESPOINTS_LW2_RED" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE" 

			 OUTPUT_LINE=$RESDIRECTOR"output_angle"
			 PROP_NAME="Output Angle"
			 Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$angle"\
			 "$id_x" "$id_angle" "non" "$LINESPOINTS_LW2_RED" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE" 

			 OUTPUT_LINE=$RESDIRECTOR"dzeta_temp"
			 PROP_NAME="Loss coeficient from temperature"
			 Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$one"\
			 "$id_x" "$id_Dzeta" "non" "$LINESPOINTS_LW2_RED" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE" 

			 OUTPUT_LINE=$RESDIRECTOR"dzeta_y"
			 PROP_NAME="Loss coeficient from pressure"
			 Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$one"\
			 "$id_x" "$id_DzetaY" "non" "$LINESPOINTS_LW2_RED" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE" 

			 OUTPUT_LINE=$RESDIRECTOR"massflow"
			 PROP_NAME="Massflow"
			 Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$massflow"\
			 "$id_x" "$id_massflow" "non" "$LINESPOINTS_LW2_RED" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE"
			 
			 OUTPUT_LINE=$RESDIRECTOR"entrophy"
			 PROP_NAME="Entrophy"
			 Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$entrophy"\
	  		 "$id_x" "$id_entrophy" "non" "$LINESPOINTS_LW2_RED" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE"
	  done

	  #najdu si pouze pro jednotlive Reynoldsovy cisla a jednotlive Machova cisla -> vytvorim grafy
	  for item in `find $RESULTDIR -type f -name "$REYNOLDS*$MACHNUMB*$SURFRESULTS" 2>>$LOG_FILE`
	  do
 			 LINESPOINTS_LW2_BLACK="with linespoints lt 1.5 lw 2"
			 OUTPUT_LINE=$RESDIRECTOR"izoentr_mach_surf"
			 PROP_NAME="Izoentropic Mach"
			 Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$one"\
	  		 "$id_x" "$id_izomach" "non" "$LINESPOINTS_LW2_BLACK" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE"

			 OUTPUT_LINE=$RESDIRECTOR"static_press_surf"
			 PROP_NAME="Static Press on blade"
			 Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$one"\
	  		 "$id_x" "$id_surf_statP" "non" "$LINESPOINTS_LW2_BLACK" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE"

			 OUTPUT_LINE=$RESDIRECTOR"coeficient_Cp"
			 PROP_NAME="Coeficient Cp"
			 Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$one"\
	  		 "$id_x" "$id_surfCp" "non" "$LINESPOINTS_LW2_BLACK" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE"
	  
	  done
}

function prepare_resdir {
	  #generate block with 2D graphs for all interesting property on surface for every calculations 
	  #@param1 Reynolds numbers of calculation
	  #@param2 Mach numbers of calculation

	  REYNO=${1:-"Unknown Property"}
	  MACHNMB=${2:-"Unknown Property"}

	  for item in `find $RESULTDIR -type f -name "*$REYNO*$MACHNMB*$SURFRESULTS" 2>>$LOG_FILE`
	  do
			 #echo $item
			 #sestavim adresar pro ukladani jednotlivych grafu
			 GRAPHSDIR=${item%*/$REYNO*$MACHNMB*$SURFRESULTS}$GRAPHSDIR_TEMPL
			 #echo $GRAPHSDIR
			 echo "PREPARE CASE $REYNO-$MACHNMB"
			 if [ -d $GRAPHSDIR ]
			 then 
					rm -rvf $GRAPHSDIR 2>>$LOG_FILE
			 fi

			 if [ ! -d $GRAPHSDIR ]
			 then
					msg="DIRECTORY $GRAPHSDIR WAS CREATED!.\n"
					STATUS="INFO"
					LogMsg $STATUS "$msg"
					mkdir --mode=$DIRRIGHTS $GRAPHSDIR 2>>$LOG_FILE
			 fi
	  done
}
###############################################################################################
# MAIN ACTION PART
###############################################################################################

LogMsg $STATUS "------ SCRIPT 2D_profiles_plt_prepare STARTED ------"

#debug flag start
#set -x

#debug flag stop
#set +x

#config file
#CfgRead

#tests your inputs
test_inputs $@

#all inputs sets and tested

# process for get result directory
if [ ! -d ${RESULTDIR:-""} ] 
 then
	  msg='YOUR DIRECTORY NOT EXIST.CHECK ITS AGAIN!'
	  STATUS="ERROR"
	  echo $msg
	  LogMsg $STATUS "SCRIPT FAILED ON RESULT DIRECTORY!\n$msg"
	  exit 2
else
	  LogMsg "INFO" "DIRECTORY $RESULTDIR - OK.\n"
fi

#hlavni nazev pro vysledny script gnuplotu
BLADENAME=$(expr "$RESULTDIR" : '.*\(R[A-Z][a-z]\(_[0-9]\{3\}\)\{4\}\+\(_[a-z]\{3\}\)\?\)')
FILENAME=${BLADENAME:-'UNDEFINED_BLADE'}$FILENAME


echo "CALCULATION PROFILE: "$BLADENAME

#process for gnuplot script generate

#first prepare skeleton for gnuplot from template
if [ ! -f $GNPL_FILETMPL ]
 then
	  msg='TEMPLATE FILE WITH HEADER OF GNUPLOT SCRIPT NOT CORRECT SET! CHECK IT!'
	  STATUS="ERROR"
	  echo $msg
	  LogMsg $STATUS "SCRIPT FAILED ON TEMPLATE FILE!\n$msg"
	  exit 2
else
	  msg="COPY THE SKELETON $GNPL_FILETMPL TO $RESULTDIR/$FILENAME"
	  STATUS="INFO"
	  LogMsg $STATUS "SCRIPT FAILED ON TEMPLATE FILE! $msg"
	  ACTUALPLOTSCRIPT=$RESULTDIR/$FILENAME
	  cp -a $GNPL_FILETMPL $ACTUALPLOTSCRIPT 2>>$LOG_FILE
fi

#create array with all Reynolds numbers and Mach numbers
#prikaz najde vsechny adresare odpovidajici masce, vezme prvni sloupec nazvu (Re01000e3), seradi a odstrani duplicity
ARRAYINDEX=0
for item in `find $RESULTDIR -type d -name "Re[0-9][0-9][0-9]*Ma0[2-9]*i0*" -print | sort | uniq 2>>$LOG_FILE`
do
	  REYNOS=$(expr $item : '.*\(Re[0-9][0-9][0-9].*\(i0.*\)\)'|cut -d \_ -f 1)
	  ARRAYOFREYNOLDS[ARRAYINDEX]=$REYNOS
	  let ARRAYINDEX++
done
SUMARRAYOFREYNOLDS=${#ARRAYOFREYNOLDS[*]}

ARRAYINDEX=0
for MACHS in `find $RESULTDIR -type d -name "$ARRAYOFREYNOLDS*Ma0[0-9]*i0*" -print | sort | uniq 2>>$LOG_FILE`
do
	  MACHS=$(expr $MACHS : '.*\(Re[0-9][0-9][0-9].*\(i0.*\)\)'|cut -d \_ -f 2)
	  ARRAYOFMACHS[ARRAYINDEX]=$MACHS
	  let ARRAYINDEX++
done
SUMARRAYOFMACHS=${#ARRAYOFMACHS[*]}

#debug info
#echo ${ARRAYOFREYNOLDS[*]}
#echo $SUMARRAYOFREYNOLDS

#echo ${ARRAYOFMACHS[*]}
#echo $SUMARRAYOFMACHS

#vygenerovani grafu pro jednotlive pripady (napr. Re10000e3_M020_i0xx)
# set terminal output
#printf "$GNPL_TERMINAL_TOPICT_TMPL" "png" "enhanced" "VeraSe" 1600 1010 >>$ACTUALPLOTSCRIPT
printf "$GNPL_TERMINAL_TOPICT_TMPL" "png" "font $FONTTERM" 1600 1010 >>$ACTUALPLOTSCRIPT

#Graphs from each calculations - averaged values
ARRAYINDEX=0
while [ "$ARRAYINDEX" -lt "$SUMARRAYOFREYNOLDS" ]
do
	  SECARRAYINDEX=0
	  while [ "$SECARRAYINDEX" -lt "$SUMARRAYOFMACHS" ]
	  do
			 REYNOLDS=${ARRAYOFREYNOLDS[$ARRAYINDEX]}
			 MACHNUMB=${ARRAYOFMACHS[$SECARRAYINDEX]}

			 #prepare_resdir "$REYNOLDS" "$MACHNUMB"

			 CALC_CASE="$BLADENAME - $REYNOLDS $MACHNUMB"

			 #najdu si pouze pro jednotlive Reynoldsovy cisla a jednotlive Machova cisla -> vytvorim grafy
			 for item in `find $RESULTDIR -type f -name "$REYNOLDS*$MACHNUMB*$AVGRESULTS" 2>>$LOG_FILE`
			 do	
					#echo $item
					#sestavim adresar pro ukladani jednotlivych grafu
					GRAPHSDIR=${item%*/$REYNOLDS*$MACHNUMB*$AVGRESULTS}$GRAPHSDIR_TEMPL
					#echo $GRAPHSDIR
					echo "PREPARE CASE $REYNOLDS-$MACHNUMB"
					if [ -d $GRAPHSDIR ]
					then 
						  rm -rvf $GRAPHSDIR 2>>$LOG_FILE  
					fi

					if [ ! -d $GRAPHSDIR ]
					then
						  msg="DIRECTORY $GRAPHSDIR WAS CREATED!.\n"
						  STATUS="INFO"
						  LogMsg $STATUS "$msg"
						  mkdir --mode=$DIRRIGHTS $GRAPHSDIR 2>>$LOG_FILE
					fi					
					
					#set format x "0.4f"
					printf "$GNPL_XFORMAT" "$GNPL_FLOAT_FORMAT_1" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
					LINESPOINTS_LW2_RED="with linespoints lt 1 lw 1.8"

					OUTPUT_LINE=$GRAPHSDIR"absolute_temp"
					Create2DGraph "Absolute Temperature" "X [mm]" "Total Temperature$kelvin"\
					"$id_x" "$id_absT" "$CALC_CASE" "$LINESPOINTS_LW2_RED" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE" 

					OUTPUT_LINE=$GRAPHSDIR"absolute_press"
					Create2DGraph "Absolute Press" "X [mm]" "Total Press$pascal"\
					"$id_x" "$id_absP" "$CALC_CASE" "$LINESPOINTS_LW2_RED" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE" 

					OUTPUT_LINE=$GRAPHSDIR"static_press"
					PROP_NAME="Static Press"
					Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$pascal"\
					"$id_x" "$id_statP" "$CALC_CASE" "$LINESPOINTS_LW2_RED" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE"

					OUTPUT_LINE=$GRAPHSDIR"static_temperature"
					PROP_NAME="Static Temperature"
					Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$kelvin"\
					"$id_x" "$id_statT" "$CALC_CASE" "$LINESPOINTS_LW2_RED" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE"
					printf "set key box lw 1\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
					printf "set key top left\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

					OUTPUT_LINE=$GRAPHSDIR"mach_number"
					PROP_NAME="Mach Number"
					Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$one"\
					"$id_x" "$id_Mach" "$CALC_CASE" "$LINESPOINTS_LW2_RED" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE" 

					printf "set key top right\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
					OUTPUT_LINE=$GRAPHSDIR"velocity_magnitude"
					PROP_NAME="Velocity Magnitude"
					Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$speed"\
					"$id_x" "$id_absV" "$CALC_CASE" "$LINESPOINTS_LW2_RED" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE" 

					OUTPUT_LINE=$GRAPHSDIR"output_angle"
					PROP_NAME="Output Angle"
					Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$angle"\
					"$id_x" "$id_angle" "$CALC_CASE" "$LINESPOINTS_LW2_RED" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE"

					OUTPUT_LINE=$GRAPHSDIR"dzeta_temp"
					PROP_NAME="Loss coeficient from temperature"
					Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$one"\
					"$id_x" "$id_Dzeta" "$CALC_CASE" "$LINESPOINTS_LW2_RED" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE"

					OUTPUT_LINE=$GRAPHSDIR"dzeta_y"
					PROP_NAME="Loss coeficient from pressure"
					Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$one"\
					"$id_x" "$id_DzetaY" "$CALC_CASE" "$LINESPOINTS_LW2_RED" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE"

					OUTPUT_LINE=$GRAPHSDIR"massflow"
					PROP_NAME="Massflow"
					Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$massflow"\
					"$id_x" "$id_massflow" "$CALC_CASE" "$LINESPOINTS_LW2_RED" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE"
			 
					OUTPUT_LINE=$GRAPHSDIR"entrophy"
					PROP_NAME="Entrophy"
					Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$entrophy"\
					"$id_x" "$id_entrophy" "$CALC_CASE" "$LINESPOINTS_LW2_RED" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE"
			 done

			 #najdu si pouze pro jednotlive Reynoldsovy cisla a jednotlive Machova cisla -> vytvorim grafy
			 for item in `find $RESULTDIR -type f -name "$REYNOLDS*$MACHNUMB*$SURFRESULTS" 2>>$LOG_FILE`
			 do

					#sestavim adresar pro ukladani jednotlivych grafu
					GRAPHSDIR=${item%*/$REYNOLDS*$MACHNUMB*$SURFRESULTS}$GRAPHSDIR_TEMPL

					LINESPOINTS_LW2_BLACK="with linespoints lc 3 lt 5 lw 1.8 "
					OUTPUT_LINE=$GRAPHSDIR"izoentr_mach_surf"
					PROP_NAME="Izoentropic Mach"
					Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$one"\
					"$id_x" "$id_izomach" "$CALC_CASE" "$LINESPOINTS_LW2_BLACK" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE"

					OUTPUT_LINE=$GRAPHSDIR"static_press_surf"
					PROP_NAME="Static Press on blade"
					Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$one"\
					"$id_x" "$id_surf_statP" "$CALC_CASE" "$LINESPOINTS_LW2_BLACK" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE"

					OUTPUT_LINE=$GRAPHSDIR"coeficient_Cp"
					PROP_NAME="Coeficient Cp"
					Create2DGraph "$PROP_NAME" "X [mm]" "$PROP_NAME$one"\
					"$id_x" "$id_surfCp" "$CALC_CASE" "$LINESPOINTS_LW2_BLACK" "$ACTUALPLOTSCRIPT" "$item" "$OUTPUT_LINE"
	  
			 done			 
			 let SECARRAYINDEX++

#plot '/media/NOne_3/Projekty/CodeDevelop/workspace/RBk_035_742_090_113_exp/lastresults/Re00100e3_Ma020_i000/data_results/Re00100e3_Ma020_i000_aver.res' every ::92 using 1:3, '/media/NOne_3/Projekty/CodeDevelop/workspace/RBk_035_742_090_113_exp/lastresults/Re00100e3_Ma030_i000/data_results/Re00100e3_Ma030_i000_aver.res' using 1:3


	  done
	  let ARRAYINDEX++
done

#Plot graphs for constant Reynolds number but different Mach number


ARRAYINDEX=0
#while [ "$ARRAYINDEX" -lt "$SUMARRAYOFREYNOLDS" ]
#do
#	  PLOT_COMMAND="plot "
#done




#plot_Ma-Dzeta ""



#ACTUALPLOTSCRIPT
#while 
#do
#done
# printf "$LOGFORMAT" "$TODAY" "$USER" "$1" "$2" >> $LOG_FILE



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
echo "NOW EXECUTE PLOTING SCRIPT, PLEASE WAIT...."
gnuplot $ACTUALPLOTSCRIPT
echo "DONE. GRAPHS GENERATED"

#End section
wait ${!}
LogEnd
exit 0
