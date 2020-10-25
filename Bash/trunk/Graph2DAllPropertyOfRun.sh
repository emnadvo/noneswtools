#!/bin/bash
#:
#: Title			: Graph2DAllPropertyOfRun.sh
#: Date			: 04.11.2011 09:28:54
#: Version		: 1.8
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
declare FILENAME='_%s.plt'
declare AVGRESULTS='_aver.res'
declare SURFRESULTS='.surf'
declare RESEXTENS='.res'
declare ZEROINCIDENCE="i000"
declare DIRRIGHTS=777

declare FONTLABEL="\"DejaVuSerif-BoldItalic,14\""
declare FONTTERM="\"arialbd\" 13"
declare FONTTITLE="\"DejaVuSans-Oblique,18\""
declare FONTKEY="\"georgia,10\""

#Gnuplot templates
declare GNPL_FLOAT_FORMAT_0="%.f"
declare GNPL_FLOAT_FORMAT_1="%.1f"
declare GNPL_FLOAT_FORMAT_2="%.2f"
declare GNPL_FLOAT_FORMAT_3="%.3f"
declare GNPL_FLOAT_FORMAT_4="%.4f"
declare GNPL_FLOAT_FORMAT_6="%.6f"
declare GNPL_FLOAT_FORMAT_8="%.8f"
declare GNPL_EXPO_FORMAT="%e"
declare GNPL_INDEX_MIN=0
declare GNPL_INDEX_MAX=114
declare LINESPOINTS_LT1_RED="with linespoints lt 1 lc 1 lw 1.8"
declare LINESPOINTS_LC3_BLUE="with linespoints lt 7 lc 2 lw 1.8"
declare POINTS_LTN="with points pt 5 ps 1 lc %d"
declare LINESMOOTH_TMPL="with lines lt 3  lc %d lw 1.8"
declare DZETA_YRANGE="set yrange[0.025:0.065]\n"

declare GNPL_NEWLINE="\n"
declare GNPL_FILETMPL=$ACTUAL_DIR/"2D_graph_plt_template.tmpl"
# font $FONTTITLE
declare GNPL_TITLE_TMPL="set title \"%s\" font $FONTTITLE\n"
declare GNPL_RANGE_TMPL="range_%d"
declare GNPL_USING_TMPL="using "
declare GNPL_STYLE_TMPL="style_%d"
declare GNPL_RANGESTYLE_LINE="%s=\"%s\"\n"

declare GNPL_XFORMAT="set format x \"%s\"\n"
declare GNPL_xLABEL="set xlabel \"%s\" offset 48, -0.35 font $FONTLABEL\n"

declare GNPL_YFORMAT="set format y \"%s\"\n"
declare GNPL_YLABEL="set ylabel \"%s\" offset 0.35, 10 font $FONTLABEL\n"

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
declare id_surf_statTemp=6
declare id_surf_yplus=7
declare id_surf_tauw=8
declare id_surf_fricU=9

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

function plot_aver2Dgraphs { 
	  #generate block with 2D graphs for all interesting property for every calculations 
	  #@param1 Reynolds numbers of calculation
	  #@param2 Mach numbers of calculation
	  #@param3 Item of calculation - *_aver.res file

	  REYNOLDS=${1:-"Unknown Property"}
	  MACHNUMB=${2:-"Unknown Property"}	  
	  ITEM=${3:-""}
	  CALC_TITLE=${4:-""}

	  #najdu si pouze pro jednotlive Reynoldsovy cisla a jednotlive Machova cisla -> vytvorim grafy
	  if [ -f $ITEM ]
	   then
			 RESDIRECTOR=${ITEM%*/$REYNOLDS*$MACHNUMB*$SURFRESULTS}$GRAPHSDIR_TEMPL
			 
			 if [ ! -f $ITEM ]
			 then
					echo "BAD ITEM "$ITEM
					exit 2
			 fi

			 XLABEL="X [mm]"

			 printf "set boxwidth 20\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 printf "set key box 3\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 
			 #set format x "0.4f"
			 printf "$GNPL_XFORMAT" "$GNPL_FLOAT_FORMAT_1" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 #==========Surface variables==========
 			 #popis vlevo nahore
			 printf "set key top left\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 printf "$GNPL_YFORMAT" "$GNPL_FLOAT_FORMAT_2" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 OUTPUT_LINE=$RESDIRECTOR"izoentr_mach_surf"
			 TITLE_GRAPH="Izoentropic Mach on blade"
			 YLABEL="Ma_izo$one"
			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL"\
	  		 "$id_x" "$id_izomach" "$CALC_TITLE" "$LINESPOINTS_LC3_BLUE" "$ACTUALPLOTSCRIPT" "$ITEM" "$OUTPUT_LINE"

			 printf "$GNPL_YFORMAT" "$GNPL_FLOAT_FORMAT_2" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 OUTPUT_LINE=$RESDIRECTOR"statTemp_surf"
			 TITLE_GRAPH="Static Temperature on blade"
			 YLABEL="T_stat$kelvin"
			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL"\
	  		 "$id_x" "$id_surf_statTemp" "$CALC_TITLE" "$LINESPOINTS_LC3_BLUE" "$ACTUALPLOTSCRIPT" "$ITEM" "$OUTPUT_LINE"

			 OUTPUT_LINE=$RESDIRECTOR"yplus_surf"
			 TITLE_GRAPH="Yplus on blade"
			 YLABEL="Y+$one"
			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL"\
	  		 "$id_x" "$id_surf_yplus" "$CALC_TITLE" "$LINESPOINTS_LC3_BLUE" "$ACTUALPLOTSCRIPT" "$ITEM" "$OUTPUT_LINE"

			 OUTPUT_LINE=$RESDIRECTOR"viscousStress_Tau_w_surf"
			 TITLE_GRAPH="Wall viscous stress on blade"
			 YLABEL="Tau_w$pascal"
			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL"\
	  		 "$id_x" "$id_surf_tauw" "$CALC_TITLE" "$LINESPOINTS_LC3_BLUE" "$ACTUALPLOTSCRIPT" "$ITEM" "$OUTPUT_LINE"

			 OUTPUT_LINE=$RESDIRECTOR"frictionSpeed_U*_surf"
			 TITLE_GRAPH="Friction speed on blade"
			 YLABEL="U*$one"
			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL"\
	  		 "$id_x" "$id_surf_fricU" "$CALC_TITLE" "$LINESPOINTS_LC3_BLUE" "$ACTUALPLOTSCRIPT" "$ITEM" "$OUTPUT_LINE"

			 printf "set key bottom left\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 printf "$GNPL_YFORMAT" "$GNPL_FLOAT_FORMAT_0" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 OUTPUT_LINE=$RESDIRECTOR"static_press_surf"
			 TITLE_GRAPH="Static Press on blade"
			 YLABEL="P_stat$pascal"
			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL"\
	  		 "$id_x" "$id_surf_statP" "$CALC_TITLE" "$LINESPOINTS_LC3_BLUE" "$ACTUALPLOTSCRIPT" "$ITEM" "$OUTPUT_LINE"

			 OUTPUT_LINE=$RESDIRECTOR"coeficient_Cp_surf"
			 TITLE_GRAPH="Coeficient Cp on blade"
			 YLABEL="C_p$one"
			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL"\
	  		 "$id_x" "$id_surfCp" "$CALC_TITLE" "$LINESPOINTS_LC3_BLUE" "$ACTUALPLOTSCRIPT" "$ITEM" "$OUTPUT_LINE"

			 #==========All domain variables==========

			 ITEM=${ITEM%*$SURFRESULTS}$AVGRESULTS
			 #popis vpravo dole
 			 printf "set key bottom right\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 printf "$GNPL_YFORMAT" "$GNPL_FLOAT_FORMAT_4" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

 			 #printf "set key font $FONTKEY\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 OUTPUT_LINE=$RESDIRECTOR"absolute_temp"
			 TITLE_GRAPH="Absolute Temperature"
			 YLABEL="T_abs$kelvin"
			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL"\
			 "$id_x" "$id_absT" "$CALC_TITLE" "$LINESPOINTS_LT1_RED" "$ACTUALPLOTSCRIPT" "$ITEM" "$OUTPUT_LINE" 

			 #popis vpravo nahore
 			 printf "set key top right\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 printf "$GNPL_YFORMAT" "$GNPL_FLOAT_FORMAT_0" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 OUTPUT_LINE=$RESDIRECTOR"static_press"
			 TITLE_GRAPH="Static Press"
			 YLABEL="P_stat$pascal"
			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL"\
			 "$id_x" "$id_statP" "$CALC_TITLE" "$LINESPOINTS_LT1_RED" "$ACTUALPLOTSCRIPT" "$ITEM" "$OUTPUT_LINE" 


			 OUTPUT_LINE=$RESDIRECTOR"absolute_press"
			 TITLE_GRAPH="Absolute Press"
			 YLABEL="P_abs$pascal"
			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL"\
			 "$id_x" "$id_absP" "$CALC_TITLE" "$LINESPOINTS_LT1_RED" "$ACTUALPLOTSCRIPT" "$ITEM" "$OUTPUT_LINE" 			 


			 printf "$GNPL_YFORMAT" "$GNPL_FLOAT_FORMAT_2" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 OUTPUT_LINE=$RESDIRECTOR"static_temperature"
			 TITLE_GRAPH="Static Temperature"
			 YLABEL="T_stat$kelvin"
			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL"\
			 "$id_x" "$id_statT" "$CALC_TITLE" "$LINESPOINTS_LT1_RED" "$ACTUALPLOTSCRIPT" "$ITEM" "$OUTPUT_LINE" 

			 #printf "$GNPL_YFORMAT" "$GNPL_FLOAT_FORMAT_2" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 OUTPUT_LINE=$RESDIRECTOR"output_angle"
			 TITLE_GRAPH="Output Angle"
			 YLABEL="Beta$angle"
			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL"\
			 "$id_x" "$id_angle" "$CALC_TITLE" "$LINESPOINTS_LT1_RED" "$ACTUALPLOTSCRIPT" "$ITEM" "$OUTPUT_LINE" 

 			 #popis vlevo nahore
			 printf "set key top left\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 OUTPUT_LINE=$RESDIRECTOR"mach_number"
			 TITLE_GRAPH="Mach Number"
			 YLABEL="Ma$one"
			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL"\
			 "$id_x" "$id_Mach" "$CALC_TITLE" "$LINESPOINTS_LT1_RED" "$ACTUALPLOTSCRIPT" "$ITEM" "$OUTPUT_LINE" 

			 printf "$GNPL_YFORMAT" "$GNPL_FLOAT_FORMAT_4" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 OUTPUT_LINE=$RESDIRECTOR"velocity_magnitude"
			 TITLE_GRAPH="Velocity Magnitude"
			 YLABEL="|V|$speed"
			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL"\
			 "$id_x" "$id_absV" "$CALC_TITLE" "$LINESPOINTS_LT1_RED" "$ACTUALPLOTSCRIPT" "$ITEM" "$OUTPUT_LINE" 

			 printf "$GNPL_YFORMAT" "$GNPL_FLOAT_FORMAT_4" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 OUTPUT_LINE=$RESDIRECTOR"dzeta_temp"
			 TITLE_GRAPH="Loss coeficient from temperature"
			 YLABEL="Dzeta$one"
			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL"\
			 "$id_x" "$id_Dzeta" "$CALC_TITLE" "$LINESPOINTS_LT1_RED" "$ACTUALPLOTSCRIPT" "$ITEM" "$OUTPUT_LINE" 

			 OUTPUT_LINE=$RESDIRECTOR"dzeta_y"
			 TITLE_GRAPH="Loss coeficient from pressure"
			 YLABEL="Y$one"
			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL"\
			 "$id_x" "$id_DzetaY" "$CALC_TITLE" "$LINESPOINTS_LT1_RED" "$ACTUALPLOTSCRIPT" "$ITEM" "$OUTPUT_LINE" 

			 printf "$GNPL_YFORMAT" "$GNPL_FLOAT_FORMAT_8" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 OUTPUT_LINE=$RESDIRECTOR"massflow"
			 TITLE_GRAPH="Massflow"
			 YLABEL="m$massflow"
			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL"\
			 "$id_x" "$id_massflow" "$CALC_TITLE" "$LINESPOINTS_LT1_RED" "$ACTUALPLOTSCRIPT" "$ITEM" "$OUTPUT_LINE"

 			 printf "$GNPL_YFORMAT" "$GNPL_FLOAT_FORMAT_2" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 OUTPUT_LINE=$RESDIRECTOR"entrophy"
			 TITLE_GRAPH="Entrophy"
			 YLABEL="S$entrophy"
			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL"\
	  		 "$id_x" "$id_entrophy" "$CALC_TITLE" "$LINESPOINTS_LT1_RED" "$ACTUALPLOTSCRIPT" "$ITEM" "$OUTPUT_LINE"

	  else
			 echo "CALCULATION \"$ITEM\" IS NOT REGULARE FILE!\nCHECK IT!"
	  fi
}

function prepare_resdir {
	  #generate block with 2D graphs for all interesting property on surface for every calculations 
	  #@param1 Reynolds numbers of calculation
	  #@param2 Mach numbers of calculation

	  REYNO=${1:-"Unknown Property"}
	  MACHNMB=${2:-"Unknown Property"}
	  ITEM=${3:-""}

	  #echo $ITEM
	  #sestavim adresar pro ukladani jednotlivych grafu
	  if [ -n "$ITEM" ]
	  then
			 GRAPHSDIR=${ITEM%*/$REYNO*$MACHNMB*$SURFRESULTS}$GRAPHSDIR_TEMPL
			 #echo $GRAPHSDIR
			 echo "PREPARE CASE $REYNO-$MACHNMB"
			 if [ -d $GRAPHSDIR ]
			 then 
					rm -rvf $GRAPHSDIR >>$LOG_FILE 2>>$LOG_FILE
			 fi
			 
			 if [ ! -d $GRAPHSDIR ]
			 then
					msg="DIRECTORY $GRAPHSDIR WAS CREATED!.\n"
					STATUS="INFO"
					LogMsg $STATUS "$msg"
					mkdir --mode=$DIRRIGHTS $GRAPHSDIR 2>>$LOG_FILE
			 fi
	  else
			 echo "UNKNOWN PATH FOR GRAPHS DIRECTORY!\nBAD CONDITION FOR PARSE HIS NAME FROM $ITEM"
			 exit 2
	  fi
}

function prepare_gpl_template {	  
	  #prepare skeleton for gnuplot program from user template
	  #@param1: FILENAME - name for new script
	  
	  SCRIPTNAME=${1:-"Undefined_name"}
	  SCRIPTDIR=${2:-"Undefined_name"}

	  if [ ! -f $GNPL_FILETMPL ]
	   then
			 msg="TEMPLATE FILE WITH HEADER OF GNUPLOT SCRIPT NOT CORRECT SET! CHECK IT!"
			 echo $msg
			 LogMsg "ERROR" "SCRIPT FAILED ON TEMPLATE FILE!\n$msg"
			 exit 2
	  else
			 msg="COPY THE SKELETON $GNPL_FILETMPL TO $SCRIPTDIR/$SCRIPTNAME"
			 LogMsg "INFO" "$msg"
			 ACTUALPLOTSCRIPT=$SCRIPTDIR/$SCRIPTNAME
			 cp -a $GNPL_FILETMPL $ACTUALPLOTSCRIPT 2>>$LOG_FILE
	  fi
}

function create_arrays_ReMa {
	  #create array with all Reynolds numbers and Mach numbers     Ma0[0-9]*i0*
	  #prikaz najde vsechny adresare odpovidajici masce, vezme prvni sloupec nazvu (Re01000e3), seradi a odstrani duplicity

	  ARRAYINDEX=0
	  echo $RESULTDIR
	  for item in `find $RESULTDIR -type f -name 'Re[0-9]*aver*' -printf '%f\n' | cut -d \_ -f 1 | sort -u 2>>$LOG_FILE`
	  do
			 #echo $item
			 #REYNOS=$(expr $item : '.*\(Re[0-9][0-9][0-9].*\(i0.*\)\)'|cut -d \_ -f 1)
			 REYNOS=$item
			 ARRAYOFREYNOLDS[ARRAYINDEX]=$REYNOS
			 let ARRAYINDEX++
	  done
	  SUMARRAYOFREYNOLDS=${#ARRAYOFREYNOLDS[*]}

	  ARRAYINDEX=0
	  for MACHS in `find $RESULTDIR -type f -name "*Ma0[0-9]*aver*" -printf '%f\n' | cut -d \_ -f 2 | sort | uniq 2>>$LOG_FILE`
	  do
			 #echo $MACHS
			 MACHS=$(expr $MACHS : '.*\(Ma[0-9]\{2\}\)'|cut -d \_ -f 2)
			 #echo $MACHS
			 ARRAYOFMACHS[ARRAYINDEX]=$MACHS
			 let ARRAYINDEX++
	  done
	  SUMARRAYOFMACHS=${#ARRAYOFMACHS[*]}
	  #echo $SUMARRAYOFMACHS
}


###############################################################################################
# MAIN ACTION PART
###############################################################################################

LogMsg $STATUS "------ SCRIPT 2D_profiles_plt_prepare STARTED ------"

#tests your inputs
test_inputs $@

#all inputs sets and tested
# process for get result directory
if [ ! -d $RESULTDIR ] 
 then
	  msg='YOUR DIRECTORY NOT EXIST.CHECK ITS AGAIN!'
	  STATUS="ERROR"
	  echo $msg
	  LogMsg $STATUS "SCRIPT FAILED ON RESULT DIRECTORY!\n$msg"
	  exit 2
fi

#hlavni nazev pro vysledny script gnuplotu
BLADENAME=$(expr "$RESULTDIR" : '.*\(R[A-Z][a-z]\(_[0-9]\{3\}\)\{4\}\+\(_[a-z]\{3\}\)\?\)')
FILENAME=${BLADENAME:-'UNDEFINED_BLADE'}$FILENAME
echo "CALCULATION PROFILE: "$BLADENAME

FILENAME=`printf "$FILENAME" "AllItems"`

#process for gnuplot script generate
prepare_gpl_template "$FILENAME" "$RESULTDIR"

#create array with all Reynolds numbers and Mach numbers
create_arrays_ReMa

#debug info
#echo ${ARRAYOFREYNOLDS[*]}
#echo $SUMARRAYOFREYNOLDS

#echo ${ARRAYOFMACHS[*]}
#echo $SUMARRAYOFMACHS

#FONTPATH="/usr/share/fonts/truetype:"
#printf "set fontpath \"$FONTPATH\"\n\n" >>$ACTUALPLOTSCRIPT

#vygenerovani grafu pro jednotlive pripady (napr. Re10000e3_M020_i0xx)
# set terminal output
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

			 CALC_CASE="$BLADENAME - $REYNOLDS $MACHNUMB"

			 #najdu si pouze pro jednotlive Reynoldsovy cisla a jednotlive Machova cisla -> vytvorim grafy
			 for item in `find $RESULTDIR -type f -name "$REYNOLDS*$MACHNUMB*$SURFRESULTS" 2>>$LOG_FILE`
			 do
					#echo $item
					prepare_resdir "$REYNOLDS" "$MACHNUMB" "$item"
					plot_aver2Dgraphs "$REYNOLDS" "$MACHNUMB" "$item" "$CALC_CASE"
			 done			 

			 let SECARRAYINDEX++
	  done
	  let ARRAYINDEX++
done

if [[ -f $ACTUALPLOTSCRIPT  &&  -f /usr/bin/gnuplot ]]
then
	  echo "NOW EXECUTE PLOTING SCRIPT, PLEASE WAIT...."
	  /usr/bin/gnuplot $ACTUALPLOTSCRIPT
	  echo "DONE. GRAPHS GENERATED"
fi

#End section
wait ${!}
LogEnd
exit 0
