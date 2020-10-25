#!/bin/bash
#:
#: Title			: Graph2DAllPropertyOfRun.sh
#: Date			: 04.11.2011 09:28:54
#: Version		: 1.2
#: Developer	: mnadvornik
#: Description	: Script for prepare plot commands for gnuplot.
#: Options		: 
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
declare LOGFORMAT="%s|%s| %s |%s\n"
declare DIVIDE="===================================\n"
declare ACTUAL_DIR=$(dirname $(readlink -f $0))
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
declare NONZEROINCIDENCE="i[0NP][0-9][0-9]"
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
declare GNPL_INDEX_MAX=130
declare LINESPOINTS_LT1_RED="with linespoints lt 1 lw 1.8"
declare LINESPOINTS_LC3_BLUE="with linespoints lt 7 lc 2 lw 1.8"
declare POINTS_LTN="with points pt 5 ps %s lc %d"
declare LINESMOOTH_TMPL="with lines lt 3  lc %d lw 1.8"
declare DZETA_YRANGE="set yrange[0.01:0.09]\n"
declare INCIDENCE_XRANGE="set xrange[-20:20]\n"
declare POINTS_SIZE="1.3"

declare GNPL_NEWLINE="\n"
declare GNPL_FILETMPL=$ACTUAL_DIR/"2D_graph_plt_template.tmpl"
# font $FONTTITLE
declare GNPL_TITLE_TMPL="set title \"%s\" font $FONTTITLE\n"
declare GNPL_RANGE_TMPL="range_%d"
declare GNPL_USING_TMPL="using "
declare GNPL_STYLE_TMPL="style_%d"
declare GNPL_EVERY_TMPL="every "
declare GNPL_INDEX_TMPL="index "
declare GNPL_RANGESTYLE_LINE="%s=\"%s\"\n"

declare GNPL_XFORMAT="set format x \"%s\"\n"
declare GNPL_xLABEL="set xlabel \"%s\" offset 45, -0.05 font $FONTLABEL\n"

declare GNPL_YFORMAT="set format y \"%s\"\n"
declare GNPL_YLABEL="set ylabel \"%s\" offset 0.35, 10 font $FONTLABEL\n"

declare GNPL_TERMINAL_TOX_TMPL="set terminal %s\n"
declare GNPL_TERMINAL_TOPICT_TMPL="set terminal %s %s size %d,%d\n"
declare GNPL_OUTPUT_TMPL="set output \"%s.%s\"\n"
declare GNPL_OUTPUT_CONST_X11="set output\n"

declare TITLEGRAPH_FINDCOND
declare GRAPHSDIR_TEMPL="/Graphs_inc/"
declare REDUCESOURCE="_datasource.dat"
declare GRAPHDIR
declare RESULTDIR
declare CALCCASE
declare BLADENAME
declare ACTUALPLOTSCRIPT
declare OUTPUT_LINE

declare -a PLOTITEMCMD
declare -a ARRAYORUNS
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
declare id_Reyno=11
declare id_absV=9
declare id_Dzeta=13
declare id_DzetaY=14
declare id_massflow=18
declare id_kinloss=17
declare id_angle=12
declare id_entrophy=15
declare id_izomach=3
declare id_incidence=17
declare id_surf_statP=4
declare id_surfCp=5
declare id_surf_statTemp=6
declare id_surf_yplus=7
declare id_surf_tauW=8
declare id_surf_fricU=9

declare pascal=" [Pa]"
declare kelvin=" [K]"
declare speed=" [m/s]"
declare angle=" [deg]"
declare one=" [1]"
declare massflow=" [kg/s]"
declare entrophy=" [J/(kg.K)]"

declare REYNOTITLE=0
declare MACHTITLE=1
declare REYMACHTITLE=2
declare INCIDENCETITLE=3

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
	  # @param 6: Style of line
	  # @param 7: Plot file to output
	  # @param 8: Data source

	  
	  FULLNAME=${1:-"Unknown Property"}
	  NAME_X=${2:-"Unknown Property"}
	  NAME_Y=${3:-"Unknown Property"}
	  ID_X=${4:-"Unknown Property"}
	  ID_Y=${5:-"Unknown Property"}
	  OUTPUTFILE=${6:-"Unknown Property"}
	  SHORTNAME=${7:-"Unknown Property"}
	  TITLETYPE=${8:-"Unknown Property"}

	  declare -a DATASRC=("${ARRAYREDUCESOURCE[@]}")
	  #echo ${DATASRC[*]}
	  SUMOFITEMS=${#DATASRC[*]}
	  TYPEITEM=-7
	  
	  if [ $SUMOFITEMS -eq 1 ]
	  then
			 #one item
			 TYPEITEM=1
	  elif [ $SUMOFITEMS -gt 1 ]
	  then
			 #more then one item
			 TYPEITEM=2
	  else
			 echo "GRAPH DON\'T CREATE WITHOUT ITEM, JACKASS! CHECK WHAT SENDING AS ITEM."
			 return 1
	  fi

#	  echo "sum of item = $SUMOFITEMS"
#	  echo "Type of item = $TYPEITEM"

	  #create graph commands - begin 
	  #set label
	  printf "$GNPL_TITLE_TMPL" "$FULLNAME" >>$OUTPUTFILE 
	  #set xlabel
	  printf "$GNPL_xLABEL" "$NAME_X" >>$OUTPUTFILE 
	  #set ylabel
	  printf "$GNPL_YLABEL" "$NAME_Y" >>$OUTPUTFILE

	  #range_1="using 2:4"
	  RANGE=$(printf "$GNPL_RANGE_TMPL" "1")
	  USING=$(printf "$GNPL_USING_TMPL$4:$5")

	  printf "$GNPL_RANGESTYLE_LINE" "$RANGE" "$USING" >>$OUTPUTFILE
	  RANGE="@$RANGE"
	  
	  if [ $TYPEITEM -eq 2 ]
	  then
			 INDEX=1
			 INDEXARRAY=0
			 LASTID=$(($SUMOFITEMS-1))
			 for (( i=0; i<$SUMOFITEMS; i++))
			 do 
					#echo $item
					get_titleitem "${DATASRC[$i]}" "$TITLETYPE"
					
					TITLE="title \'$ITEMTITLE\'"
					#TITLE="notitle"

					#style_1="ls 2" - one style for points
					POINTSTYLE=$(printf "$GNPL_STYLE_TMPL" "$INDEX")
					STYLEDEF=`printf "$POINTS_LTN" "$POINTS_SIZE" "$INDEX"`
					printf "$GNPL_RANGESTYLE_LINE" "$POINTSTYLE" "$STYLEDEF" >>$OUTPUTFILE
					POINTSTYLE="@$POINTSTYLE"
	  
					#style_1="ls 2" - one style for smooth line
					STYLEDEF=`printf "$LINESMOOTH_TMPL" "$INDEX"`
					let INDEX++					
					LINESMOOTHSTYLE=$(printf "$GNPL_STYLE_TMPL" "$INDEX")

					printf "$GNPL_RANGESTYLE_LINE" "$LINESMOOTHSTYLE" "$STYLEDEF" >>$OUTPUTFILE
					LINESMOOTHSTYLE="@$LINESMOOTHSTYLE"

					FINALLINE=$(printf "\'%s\' $RANGE $POINTSTYLE notitle, \'%s\' $RANGE $LINESMOOTHSTYLE $TITLE"\
								 "${DATASRC[$i]}" "${DATASRC[$i]}")
					
					#echo "Indexarray = $INDEXARRAY"
					#echo "LastID = $LASTID"

					if [ $INDEXARRAY -lt $LASTID ]
					then 
						  FINALLINE=$FINALLINE","
					fi
					
					#echo $FINALLINE
	  
					PLOTITEMCMD[INDEXARRAY]=$FINALLINE
					let INDEXARRAY++
					let INDEX++
			 done

	  elif [ $TYPEITEM -eq 1 ]; then

			 INDEX=1
			 INDEXARRAY=0
			 #echo $item
			 get_titleitem "${DATASRC[$INDEXARRAY]}" "$TITLETYPE"
			
			 TITLE="title \'$ITEMTITLE\'"
			 #TITLE="notitle"

			 #style_1="ls 2" - one style for points
			 POINTSTYLE=$(printf "$GNPL_STYLE_TMPL" "$INDEX")
			 STYLEDEF=`printf "$POINTS_LTN" "$POINTS_SIZE" "$INDEX"`
			 printf "$GNPL_RANGESTYLE_LINE" "$POINTSTYLE" "$STYLEDEF" >>$OUTPUTFILE
			 POINTSTYLE="@$POINTSTYLE"
			 
			 #style_1="ls 2" - one style for smooth line
			 STYLEDEF=`printf "$LINESMOOTH_TMPL" "$INDEX"`
			 let INDEX++					
			 LINESMOOTHSTYLE=$(printf "$GNPL_STYLE_TMPL" "$INDEX")

			 printf "$GNPL_RANGESTYLE_LINE" "$LINESMOOTHSTYLE" "$STYLEDEF" >>$OUTPUTFILE
			 LINESMOOTHSTYLE="@$LINESMOOTHSTYLE"

			 FINALLINE=$(printf "\'%s\' $RANGE $POINTSTYLE notitle, \'%s\' $RANGE $LINESMOOTHSTYLE $TITLE"\
							 "${DATASRC[$INDEXARRAY]}" "${DATASRC[$INDEXARRAY]}")
					
			 #echo $FINALLINE
	  
			 PLOTITEMCMD[INDEXARRAY]=$FINALLINE

	  fi
	  
	  if [ ${#PLOTITEMCMD[*]} -gt 0 ] 
	  then
			 #set output "nazev.png"
			 printf "$GNPL_OUTPUT_TMPL"  "$SHORTNAME" "$GRAPHEXT" >>$OUTPUTFILE
			 printf "plot %s\n" "${PLOTITEMCMD[*]}" >>$OUTPUTFILE
			 printf "$GNPL_NEWLINE" >>$OUTPUTFILE
			 unset PLOTITEMCMD
	  fi
} 


function get_titleitem {
	  #function return name of item
	  #@param1: item
	  #@param2: type of item 0 - Reynolds, 1 - Mach, 2 - Reynolds and Mach
	  FULLITEM=${1:-""}
	  ITEMTYPE=${2:-""}

	  if [ -n $FULLITEM ]
	  then
			 case "$ITEMTYPE" in
					0)
						  ITEMTITLE=$(expr "$FULLITEM" : '.*\(Re[0-9][0-9][0-9][0-9].*e3\)')
					;;
					1)
						  ITEMTITLE=$(expr "$FULLITEM" : '.*\(Ma[0-9][0-9]0\)')
					;;
					2)
						  ITEMTITLE=$(expr "$FULLITEM" : '.*\(Re[0-9][0-9][0-9][0-9].*e3.*\(Ma[0-9][0-9]0\)\)')
					;;
					3)
						  ITEMTITLE=$(expr "$FULLITEM" : '.*\(i[0NP][0-9]\{2\}\)')
					;;
					*)
						  ITEMTITLE="UNKNOWN"
			 esac
	  fi

	  if [ -z $ITEMTITLE ]
	  then
			 ITEMTITLE="NONDEFINED_BLADE"
	  fi
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


function plot_graphsDependIncidence { 
	  #generate block with 2D graphs for all interesting property for every calculations 
	  
	  #najdu si pouze pro jednotlive Reynoldsovy cisla a jednotlive Machova cisla -> vytvorim grafy
	  if [ $COUNTSOURCE -gt 1 ]
	   then
			 #printf "set boxwidth 20\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 #printf "set key box 3\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 REYNOLDSTL=$(expr "${ARRAYREDUCESOURCE[0]}" : '.*\(Re[0-9]\{5\}.*e3\)')
			 #echo $REYNOLDSTL
			 #popis vlevo nahore
			 printf "set key top right\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 #set xrange for incidence
			 printf "$INCIDENCE_XRANGE" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 #set yrange for dzeta
			 #printf "$DZETA_YRANGE" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 printf "$GNPL_YFORMAT" "$GNPL_FLOAT_FORMAT_4" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 #popis vlevo nahore
			 printf "set key center left\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

		 #graph Dzeta-Ma
			 echo "GENERATE GRAPHS DZETA - INCIDENCE FOR ALL INCIDENCE INFLUENCE"

			 XLABEL="inc $angle"

			 OUTPUT_LINE=$GRAPHDIR/$BLADENAME"_"$REYNOLDSTL"_dzeta_inc"
			 TITLE_GRAPH="Loss coeficient from temperature for $BLADENAME"
			 YLABEL="Dzeta$one"

			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL" "$id_incidence" "$id_Dzeta" \
			 "$ACTUALPLOTSCRIPT" "$OUTPUT_LINE" "$REYMACHTITLE"

  		 #graph Y-Ma
			 echo "GENERATE GRAPHS Y - INCIDENCE FOR ALL INCIDENCE INFLUENCE"	

			 OUTPUT_LINE=$GRAPHDIR/$BLADENAME"_"$REYNOLDSTL"_Y_inc"
			 TITLE_GRAPH="Loss coeficient from pressure for $BLADENAME"
			 YLABEL="Y$one"

			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL" "$id_incidence" "$id_DzetaY" \
			 "$ACTUALPLOTSCRIPT" "$OUTPUT_LINE" "$REYMACHTITLE"

  		 #graph OutAngle-Ma
			 echo "GENERATE GRAPHS BETAOUT - INCIDENCE FOR ALL INCIDENCE INFLUENCE"	

			 printf "$GNPL_YFORMAT" "$GNPL_FLOAT_FORMAT_2" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 OUTPUT_LINE=$GRAPHDIR/$BLADENAME"_"$REYNOLDSTL"_outangle_inc"
			 TITLE_GRAPH="Output angle for $BLADENAME"
			 YLABEL="Beta_out$angle"

			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL" "$id_incidence" "$id_angle" \
			 "$ACTUALPLOTSCRIPT" "$OUTPUT_LINE" "$REYMACHTITLE"

  		 #graph S-Ma
			 echo "GENERATE GRAPHS ENTROPHY - INCIDENCE FOR ALL INCIDENCE INFLUENCE"	

			 printf "$GNPL_YFORMAT" "$GNPL_FLOAT_FORMAT_2" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 OUTPUT_LINE=$GRAPHDIR/$BLADENAME"_"$REYNOLDSTL"_entropy_inc"
			 TITLE_GRAPH="Entropy for $BLADENAME"
			 YLABEL="S$entrophy"

			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL" "$id_incidence" "$id_entrophy" \
			 "$ACTUALPLOTSCRIPT" "$OUTPUT_LINE" "$REYMACHTITLE"

  		 #graph absT-Ma
			 echo "GENERATE GRAPHS ABSOLUTE TEMPERATURE - INCIDENCE FOR ALL INCIDENCE INFLUENCE"	

			 OUTPUT_LINE=$GRAPHDIR/$BLADENAME"_"$REYNOLDSTL"_absT_inc"
			 TITLE_GRAPH="Absolute temperature for $BLADENAME"
			 YLABEL="T_abs$kelvin"

			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL" "$id_incidence" "$id_absT" \
			 "$ACTUALPLOTSCRIPT" "$OUTPUT_LINE" "$REYMACHTITLE"

  		 #graph |v|-Ma
			 echo "GENERATE GRAPHS VELOCITY MAGNITUDE - INCIDENCE FOR ALL INCIDENCE INFLUENCE"	

			 OUTPUT_LINE=$GRAPHDIR/$BLADENAME"_"$REYNOLDSTL"_magnitudeV_inc"
			 TITLE_GRAPH="Velocity magnitude for $BLADENAME"
			 YLABEL="|V|$speed"

			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL" "$id_incidence" "$id_absV" \
			 "$ACTUALPLOTSCRIPT" "$OUTPUT_LINE" "$REYMACHTITLE"

  		 #graph Pstat-Ma
			 echo "GENERATE GRAPHS STATIC PRESSURE - INCIDENCE FOR ALL INCIDENCE INFLUENCE"	

			 #popis vlevo nahore
			 printf "set key bottom left\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 printf "set logscale y\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 OUTPUT_LINE=$GRAPHDIR/$BLADENAME"_"$REYNOLDSTL"_Pstat_inc"
			 TITLE_GRAPH="Static pressure for $BLADENAME"
			 YLABEL="log P_stat$pascal"

			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL" "$id_incidence" "$id_statP" \
			 "$ACTUALPLOTSCRIPT" "$OUTPUT_LINE" "$REYMACHTITLE"

  		 #graph Pabs-Ma
			 echo "GENERATE GRAPHS ABSOLUTE PRESSURE - INCIDENCE FOR ALL INCIDENCE INFLUENCE"	

			 #popis vlevo nahore
			 printf "set key bottom left\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE			 

			 OUTPUT_LINE=$GRAPHDIR/$BLADENAME"_"$REYNOLDSTL"_Pabs_inc"
			 TITLE_GRAPH="Absolute pressure for $BLADENAME"
			 YLABEL="log P_abs$pascal"

			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL" "$id_incidence" "$id_absP" \
			 "$ACTUALPLOTSCRIPT" "$OUTPUT_LINE" "$REYMACHTITLE"

			 printf "unset logscale y\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
	  else
			 echo "SOURCE \"$ARRAYREDUCESOURCE\" IS NOT ARRAY FOR REYNOLDS GRAPHS!\nCHECK IT!"
	  fi
}

function plot_graphsDependMach {

	  #najdu si pouze pro jednotlive Reynoldsovy cisla a jednotlive Machova cisla -> vytvorim grafy
	  if [ $COUNTSOURCE -ge 1 ]
	   then
			 #set logarithm scale for x
			 printf "set logscale x\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 printf "set xrange [80000:10500000]\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 printf "set xtics (100000,250000,500000,1000000,2500000,5000000,10000000)\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 printf "set autoscale y\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 #popis vlevo nahore
			 printf "set key top right\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 #set yrange for dzeta
			 printf "$GNPL_YFORMAT" "$GNPL_FLOAT_FORMAT_4" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 #set format x "%2.1ecd .."
			 printf "$GNPL_XFORMAT" "%2.1e" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 XLABEL="log Re$one"

		 #graph Dzeta-Rey
			 echo "GENERATE GRAPHS DZETA - REYNOLDS FOR ALL MACH NUMBERS WITHOUT INCIDENCE INFLUENCE"

			 OUTPUT_LINE=$GRAPHDIR/$BLADENAME"_dzeta_rey"
			 TITLE_GRAPH="Loss coeficient from temperature for $BLADENAME"
			 YLABEL="Dzeta$one"

			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL" "$id_Reyno" "$id_Dzeta" \
			 "$ACTUALPLOTSCRIPT" "$OUTPUT_LINE" "$MACHTITLE"

		 #graph DzetaKin-Rey
			 echo "GENERATE GRAPHS KINLOSS - REYNOLDS FOR ALL MACH NUMBERS WITHOUT INCIDENCE INFLUENCE"

			 OUTPUT_LINE=$GRAPHDIR/$BLADENAME"_kinloss_rey"
			 TITLE_GRAPH="Loss coeficient from velocity for $BLADENAME"
			 YLABEL="Dzeta_kin$one"

			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL" "$id_Reyno" "$id_kinloss" \
			 "$ACTUALPLOTSCRIPT" "$OUTPUT_LINE" "$MACHTITLE"

		 #graph DzetaY-Rey
#			 echo "GENERATE GRAPHS Y - REYNOLDS FOR ALL MACH NUMBERS WITHOUT INCIDENCE INFLUENCE"

#			 OUTPUT_LINE=$GRAPHDIR/$BLADENAME"_y_rey"
#			 TITLE_GRAPH="Loss coeficient from pressure for $BLADENAME"
#			 YLABEL="Y$one"

#			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL" "$id_Reyno" "$id_DzetaY" \
#			 "$ACTUALPLOTSCRIPT" "$OUTPUT_LINE" "$MACHTITLE"


		 #graph Entrophy-Rey
			 echo "GENERATE GRAPHS ENTROPY - REYNOLDS FOR ALL MACH NUMBERS WITHOUT INCIDENCE INFLUENCE"
			 
			 printf "$GNPL_YFORMAT" "$GNPL_FLOAT_FORMAT_0" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE			 
			 
			 OUTPUT_LINE=$GRAPHDIR/$BLADENAME"_entrophy_rey"
			 TITLE_GRAPH="Entrophy for $BLADENAME"
			 YLABEL="S$entrophy"

			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL" "$id_Reyno" "$id_entrophy" \
			 "$ACTUALPLOTSCRIPT" "$OUTPUT_LINE" "$MACHTITLE"


		 #graph MagnitudeV-Rey
			 echo "GENERATE GRAPHS MAGNITUDE V - REYNOLDS FOR ALL MACH NUMBERS WITHOUT INCIDENCE INFLUENCE"

			 #popis vpravo dole
			 printf "set key top left\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 OUTPUT_LINE=$GRAPHDIR/$BLADENAME"_magnV_rey"
			 TITLE_GRAPH="Magnitude V for $BLADENAME"
			 YLABEL="|V|$speed"

			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL" "$id_Reyno" "$id_absV" \
			 "$ACTUALPLOTSCRIPT" "$OUTPUT_LINE" "$MACHTITLE"


		 #graph Angle-Rey
			 echo "GENERATE GRAPHS OUTPUT ANGLE - REYNOLDS FOR ALL MACH NUMBERS WITHOUT INCIDENCE INFLUENCE"
			 printf "$GNPL_YFORMAT" "$GNPL_FLOAT_FORMAT_2" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 #popis vpravo dole
			 printf "set key top left\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 OUTPUT_LINE=$GRAPHDIR/$BLADENAME"_outangle_rey"
			 TITLE_GRAPH="Output angle for $BLADENAME"
			 YLABEL="beta_out$angle"

			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL" "$id_Reyno" "$id_angle" \
			 "$ACTUALPLOTSCRIPT" "$OUTPUT_LINE" "$MACHTITLE"

			 printf "unset logscale x\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

	  else
			 echo "SOURCE \"$ARRAYREDUCESOURCE\" IS NOT ARRAY FOR MACHS GRAPHS!\nCHECK IT!"
	  fi

}


function plot_graphsSurface {
	  #najdu si pouze pro jednotlive Reynoldsovy cisla a jednotlive Machova cisla -> vytvorim grafy
	  if [ $COUNTSOURCE -gt 1 ]
	   then
			 #set logarithm scale for x
			 printf "set xtics 5\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 REYNOLDSTL=$(expr "${ARRAYREDUCESOURCE[0]}" : '.*\(Re[0-9]\{5\}.*e3.*\(Ma[0-9][0-9]0\)\)')
			 #MACHNUM=$(expr "${ARRAYREDUCESOURCE[0]}" : '.*\(Ma[0-9][0-9]0\)')
			 #echo $REYNOLDSTL
			 #popis vlevo nahore
			 printf "set key bottom left\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 #set x,y format
			 printf "$GNPL_YFORMAT" "$GNPL_FLOAT_FORMAT_2" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 printf "$GNPL_XFORMAT" "$GNPL_FLOAT_FORMAT_2" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 printf "set autoscale y\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE
			 printf "set autoscale x\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 XLABEL="X [mm]"

		 #graph X-Cp
			 echo "GENERATE GRAPHS X - PRESS COEFICIENT CP FOR ALL MACH NUMBERS ON BLADE SURFACE"

			 printf "set key bottom left\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 OUTPUT_LINE=$GRAPHDIR/$BLADENAME"_"$REYNOLDSTL"_bladeX_Cp"
			 TITLE_GRAPH="Press coeficient Cp on surface for $BLADENAME and $REYNOLDSTL"
			 YLABEL="Cp$one"

			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL" "$id_x" "$id_surfCp" \
			 "$ACTUALPLOTSCRIPT" "$OUTPUT_LINE" "$INCIDENCETITLE"

		 #graph X-Maizo
			 echo "GENERATE GRAPHS X - IZOENTROPIC MACH FOR ALL MACH NUMBERS ON BLADE SURFACE"

			 printf "set key top left\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 OUTPUT_LINE=$GRAPHDIR/$BLADENAME"_"$REYNOLDSTL"_bladeX_MaIzo"
			 TITLE_GRAPH="Izoentropic Mach on surface for $BLADENAME and $REYNOLDSTL"
			 YLABEL="Ma_izo$one"

			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL" "$id_x" "$id_izomach" \
			 "$ACTUALPLOTSCRIPT" "$OUTPUT_LINE" "$INCIDENCETITLE"

		 #graph X-T stat
			 echo "GENERATE GRAPHS X - STATIC TEMPERATURE FOR ALL MACH NUMBERS ON BLADE SURFACE"

			 printf "set key bottom left\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 OUTPUT_LINE=$GRAPHDIR/$BLADENAME"_"$REYNOLDSTL"_bladeX_statTemp"
			 TITLE_GRAPH="Static Temperature on surface for $BLADENAME and $REYNOLDSTL"
			 YLABEL="T_stat$kelvin"

			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL" "$id_x" "$id_surf_statTemp" \
			 "$ACTUALPLOTSCRIPT" "$OUTPUT_LINE" "$INCIDENCETITLE"

		 #graph X-Yplus
			 echo "GENERATE GRAPHS X - Y PLUS FOR ALL MACH NUMBERS ON BLADE SURFACE"

			 printf "set key top left\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 OUTPUT_LINE=$GRAPHDIR/$BLADENAME"_"$REYNOLDSTL"_bladeX_yplus"
			 TITLE_GRAPH="Y+ on surface for $BLADENAME and $REYNOLDSTL"
			 YLABEL="Y+$one"

			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL" "$id_x" "$id_surf_yplus" \
			 "$ACTUALPLOTSCRIPT" "$OUTPUT_LINE" "$INCIDENCETITLE"

		 #graph X-Tau_w
			 echo "GENERATE GRAPHS X - Tau_w FOR ALL MACH NUMBERS ON BLADE SURFACE"

			 #printf "set key top left\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 OUTPUT_LINE=$GRAPHDIR/$BLADENAME"_"$REYNOLDSTL"_bladeX_tauW"
			 TITLE_GRAPH="Tau_w on surface for $BLADENAME and $REYNOLDSTL"
			 YLABEL="Tau_w$pascal"

			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL" "$id_x" "$id_surf_tauW" \
			 "$ACTUALPLOTSCRIPT" "$OUTPUT_LINE" "$INCIDENCETITLE"

		 #graph X-U*
			 echo "GENERATE GRAPHS X - U* FOR ALL MACH NUMBERS ON BLADE SURFACE"

			 #printf "set key top left\n" >>$ACTUALPLOTSCRIPT 2>>$LOG_FILE

			 OUTPUT_LINE=$GRAPHDIR/$BLADENAME"_"$REYNOLDSTL"_bladeX_fricU"
			 TITLE_GRAPH="U* on surface for $BLADENAME and $REYNOLDSTL"
			 YLABEL="U*$one"

			 Create2DGraph "$TITLE_GRAPH" "$XLABEL" "$YLABEL" "$id_x" "$id_surf_fricU" \
			 "$ACTUALPLOTSCRIPT" "$OUTPUT_LINE" "$INCIDENCETITLE"

	  else
			 echo "SOURCE \"$ARRAYREDUCESOURCE\" IS NOT ARRAY FOR MACHS GRAPHS!\nCHECK IT!"
	  fi	  

}


function prepare_resdir {
	  #generate block with 2D graphs for all interesting property on surface for every calculations 
	  #@param1 Reynolds numbers of calculation
	  #@param2 Mach numbers of calculation

	  DIRECTORY=${1:-""}

	  #echo $DIRECTORY
	  #sestavim adresar pro ukladani jednotlivych grafu
	  GRAPHDIR=$DIRECTORY$GRAPHSDIR_TEMPL
	  #echo $DIRECTORY
	  if [ -n "$GRAPHDIR" ]
	  then
			 if [ -d $GRAPHDIR ]
			 then 
					rm -rvf $GRAPHDIR >>$LOG_FILE 2>>$LOG_FILE
			 fi
			 
			 if [ ! -d $GRAPHDIR ]
			 then
					msg="DIRECTORY $GRAPHDIR WAS CREATED!.\n"
					STATUS="INFO"
					LogMsg $STATUS "$msg"
					mkdir --mode=$DIRRIGHTS $GRAPHDIR 2>>$LOG_FILE
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
	  for item in `find $RESULTDIR -type f -name 'Re[0-9]*i[N-P][0-9][0-9]*aver*' -printf '%f\n' | cut -d \_ -f 1 | sort -u 2>>$LOG_FILE`
	  do
			 #echo $item
			 REYNOS=$item
			 ARRAYOFREYNOLDS[ARRAYINDEX]=$REYNOS
			 let ARRAYINDEX++
	  done
	  SUMARRAYOFREYNOLDS=${#ARRAYOFREYNOLDS[*]}

	  ARRAYINDEX=0
	  for MACHS in `find $RESULTDIR -type f -name "*Ma0[0-9]*i[N-P][0-9][0-9]*aver*" -printf '%f\n' | cut -d \_ -f 2 | sort -u 2>>$LOG_FILE`
	  do	
			 #echo $MACHS		 
			 #MACHS=$(expr $MACHS : '.*\(Ma[0-9]\{2\}\)'|cut -d \_ -f 2)
			 #echo $MACHS
			 ARRAYOFMACHS[ARRAYINDEX]=$MACHS
			 let ARRAYINDEX++
	  done
	  SUMARRAYOFMACHS=${#ARRAYOFMACHS[*]}
}


###############################################################################################
# MAIN ACTION PART
###############################################################################################

LogMsg $STATUS "------ SCRIPT 2D Graph of variables depend on Reynolds or Mach number STARTED ------"

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

echo "ARRAYS OF REYNOLDS AND MACHS NUMBERS IS GENERATING....WAIT..."
#create array with all Reynolds numbers and Mach numbers
create_arrays_ReMa

#debug info
#echo ${ARRAYOFREYNOLDS[*]}
#echo $SUMARRAYOFREYNOLDS
#echo ${ARRAYOFMACHS[*]}
#echo $SUMARRAYOFMACHS

#base name for gnuplot scripts
#BLADENAME=$(expr "$RESULTDIR" : '.*\(R[A-Z][a-z]\(_[0-9]\{3\}\)\{4\}\+\(_[a-z]\{3\}\)\?\)')
BLADENAME=$(expr "$RESULTDIR" : '.*\([A-Z][A-Z][a-z]\(_[0-9]\{3\}\)\(_[0-9]\{4\}\)\(_[0-9]\{3\}\)\{2\}\+\(_[a-z]\{3\}\)\?\)')
#Filename PROFILE_%s.gpl - not final!
FILENAME=${BLADENAME:-'UNDEFINED_BLADE'}$FILENAME

#create directory for graphs $GRAPHDIR
prepare_resdir "$RESULTDIR"

#process for gnuplot script generate
SCRIPTNAME=`printf "$FILENAME" "all_calc_graphs_inc"`
prepare_gpl_template "$SCRIPTNAME" "$GRAPHDIR"

# set terminal output
printf "$GNPL_TERMINAL_TOPICT_TMPL" "png" "font $FONTTERM" 1600 1010 >>$ACTUALPLOTSCRIPT

#======================================================================================================
# dependence on Reynolds

#Get all data from all runs - averaged values
declare -a ARRAYREDUCESOURCE
ARRAYINDEX=0
while [ "$ARRAYINDEX" -lt "$SUMARRAYOFREYNOLDS" ]
do	  
	  REYNOLDS=${ARRAYOFREYNOLDS[$ARRAYINDEX]}

	  SECARRAYINDEX=0
	  #create datasource from all runs with incidence influence
	  while [ "$SECARRAYINDEX" -lt "$SUMARRAYOFMACHS" ]
	  do
			 HEADER_INSERT=0 
			 MACH=${ARRAYOFMACHS[$SECARRAYINDEX]}
			 REDUCE_DATASOURCE=$GRAPHDIR$REYNOLDS$MACH$REDUCESOURCE
# negative incidence
			 for item in `find $RESULTDIR -type f -name "*$REYNOLDS*$MACH*iN[0-9][0-9]*$AVGRESULTS" | sort -rt \_ -k 3 2>>$LOG_FILE`
			 do
					#echo $item
					INCIDENCE=`expr $item : '.*\(N[0-9]\{2\}\)'`
					INCSGN=${INCIDENCE:0:1}
					INCVAL="-"${INCIDENCE:1}
					
					#Get header of columns
					if [ $HEADER_INSERT -eq 0 ]
					then
						  head -n 3 $item | tail -n -1 > $REDUCE_DATASOURCE
						  HEADER_INSERT=1
					fi

					line=`head -n $GNPL_INDEX_MAX $item | tail -n -1`
					line=`printf "%s\t%s" "$line" "$INCVAL"`
					echo $line >> $REDUCE_DATASOURCE
			 done

# zero incidence
			 for item in `find $RESULTDIR -type f -name "*$REYNOLDS*$MACH*i0[0-9][0-9]*$AVGRESULTS" | sort -rt \_ -k 3 2>>$LOG_FILE`
			 do
					#echo $item
					INCIDENCE=`expr $item : '.*\(0[0-9]\{2\}\)'`
					INCSGN=${INCIDENCE:0:1}
					INCVAL=${INCIDENCE:1}

					#Get header of columns
					if [ $HEADER_INSERT -eq 0 ]
					then
						  head -n 3 $item | tail -n -1 > $REDUCE_DATASOURCE
						  HEADER_INSERT=1
					fi

					line=`head -n $GNPL_INDEX_MAX $item | tail -n -1`
					line=`printf "%s\t%s" "$line" "$INCVAL"`
					echo $line >> $REDUCE_DATASOURCE
			 done

# positive incidence
			 for item in `find $RESULTDIR -type f -name "*$REYNOLDS*$MACH*iP[0-9][0-9]*$AVGRESULTS" | sort -t \_ -k 3 2>>$LOG_FILE`
			 do
					#echo $item
					INCIDENCE=`expr $item : '.*\(P[0-9]\{2\}\)'`
					INCSGN=${INCIDENCE:0:1}
					INCVAL=${INCIDENCE:1}
					
					#Get header of columns
					if [ $HEADER_INSERT -eq 0 ]
					then
						  head -n 3 $item | tail -n -1 > $REDUCE_DATASOURCE
						  HEADER_INSERT=1
					fi

					line=`head -n $GNPL_INDEX_MAX $item | tail -n -1`
					line=`printf "%s\t%s" "$line" "$INCVAL"`
					echo $line >> $REDUCE_DATASOURCE
			 done

			 if [ -f $REDUCE_DATASOURCE ]
			 then
					ARRAYREDUCESOURCE[SECARRAYINDEX]=$REDUCE_DATASOURCE
			 fi
			 
			 let SECARRAYINDEX++

	  done

	  #debug info
	  #echo ${ARRAYREDUCESOURCE[*]}

	  COUNTSOURCE=${#ARRAYREDUCESOURCE[*]}
	  #echo $COUNTSOURCE
	  if [ $COUNTSOURCE -gt 1 ]
	  then			
			 plot_graphsDependIncidence
	  fi
  	  #and again for other Reynolds number
	  let ARRAYINDEX++
done

#debug info
#echo ${ARRAYREDUCESOURCE[*]}
#echo ${#ARRAYREDUCESOURCE[*]}


#Generate graph for reduce datasource
COUNTSOURCE=${#ARRAYREDUCESOURCE[*]}
#echo $COUNTSOURCE
if [ $COUNTSOURCE -ge 1 ]
then			
	  plot_graphsDependMach
fi
unset ARRAYREDUCESOURCE


#======================================================================================================
# all surfaces

#Get all data from all runs - averaged values
ARRAYINDEX=0
REYARRAY="0"

POINTS_SIZE=0

while [ "$REYARRAY" -lt "$SUMARRAYOFREYNOLDS" ]
do	  
	  REYNOLDS=${ARRAYOFREYNOLDS[$REYARRAY]}
	  MACHARRAYINDEX=0

	  #create datasource from all runs with incidence influence
	  while [ "$MACHARRAYINDEX" -lt "$SUMARRAYOFMACHS" ]
	  do
			 MACH=${ARRAYOFMACHS[$MACHARRAYINDEX]}
			 #create datasource from all runs without incidence influence	  
			 for item in `find $RESULTDIR -type f -name "*$REYNOLDS*$MACH*$NONZEROINCIDENCE*$SURFRESULTS" | sort 2>>$LOG_FILE`
			 do
					#echo $item
					ARRAYREDUCESOURCE[ARRAYINDEX]=$item
					let ARRAYINDEX++
			 done

			 #Generate graph for reduce datasource
			 COUNTSOURCE=${#ARRAYREDUCESOURCE[*]}
			 #echo $COUNTSOURCE
			 if [ $COUNTSOURCE -gt 1 ]
			 then
					plot_graphsSurface
			 fi

			 unset ARRAYREDUCESOURCE
			 ARRAYINDEX=0
			 let MACHARRAYINDEX++
	  done
	  
	  let REYARRAY++
	  #debug info
	  #echo ${ARRAYREDUCESOURCE[*]}
	  #echo ${#ARRAYREDUCESOURCE[*]}
done


if [[ -f $ACTUALPLOTSCRIPT  &&  -f /usr/bin/gnuplot ]]
then
	  echo "NOW EXECUTE PLOTING SCRIPT, PLEASE WAIT...."
	  /usr/bin/gnuplot $ACTUALPLOTSCRIPT
	  echo "DONE. GRAPHS GENERATED"
fi
#End section
wait ${!}
#LogEnd
exit 0
