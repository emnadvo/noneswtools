#!/bin/bash
#:
#: Title			: extract_2D_profile_from_GeomTurbo.sh
#: Date			: 24.06.2014 11:59:30
#: Version		: 1.0
#: Developer	: mnadvornik
#: Description	: Script for extract points of 2d profile from geomTurbo file and plot png with this profile in gnuplot
#: Options		: 
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
declare LOGFORMAT="%s|%s| %s |%s\n"
declare DIVIDE="===================================\n"
declare ACTUAL_DIR=$(dirname $(readlink -f $0))
declare LOG_FILE=$ACTUAL_DIR/".log"
declare STATUS="INFO"
declare MSG
declare TODAY=$(date '+%d.%m.%Y %H:%M:%S')
declare SCRIPTCFG="$ACTUAL_DIR/Data/extract_2D_profile_from_GeomTurbo.cfg"
declare -a SCRPROPERTY
declare ARRAYSIZE=0


# GNUPLOT VARIABLES

declare FONTLABEL="\"DejaVuSerif-BoldItalic,14\""
declare FONTTERM="\"arialbd\" 13"
declare FONTTITLE="\"DejaVuSans-Oblique,18\""
declare FONTKEY="\"georgia,10\""
declare GNPL_FLOAT_FORMAT_0="%.f"
declare GNPL_FLOAT_FORMAT_1="%.1f"
declare GNPL_FLOAT_FORMAT_2="%.2f"
declare GNPL_FLOAT_FORMAT_3="%.3f"
declare GNPL_FLOAT_FORMAT_4="%.4f"
declare GNPL_FLOAT_FORMAT_6="%.6f"
declare GNPL_FLOAT_FORMAT_8="%.8f"
declare GNPL_EXPO_FORMAT="%e"
declare GNPL_NEWLINE="\n"
declare GNPL_FILETMPL=$ACTUAL_DIR/"profile2D_plot_templ.plt"

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
			 msg='NEED INPUT PARAMETER WHICH IS GEOMTURBO FILE!'
			 echo $msg
			 echo 'INSERT PATH OF GEOMTURBO FILE'
			 read SOURCEFILE
	  else
			 SOURCEFILE="${1:-""}"
	  fi
}

###############################################################################################
# MAIN ACTION PART
###############################################################################################

#LogMsg $STATUS "------ SCRIPT  STARTED ------"

#debug flag start
#set -x

#debug flag stop
#set +x

#CfgRead

#tests your inputs
test_inputs $@

declare GNUPLOT_TEMPL=''


if [ -f $SOURCEFILE ]; then
	  NAME=$(basename $SOURCEFILE | cut -d \. -f 1)
	  SRCDIR=$(dirname $SOURCEFILE)
	  NEWNAME=$SRCDIR/$NAME.dat
	  SUCTIONSIDE=$SRCDIR/suction_side.dat
	  PRESSURESIDE=$SRCDIR/pressure_side.dat
	  GNPLNEWNAME=$SRCDIR/$NAME.plt

	  dos2unix -o $SOURCEFILE;

	  awk '/PRESSURE/, G {print $0}' $SOURCEFILE | awk '{if($0 ~ /[[:digit:]]/ && $0 !~ /\+/ && NF == 3){print $0;}}' > $PRESSURESIDE
	  awk '/SUCTION/,/PRESSURE/  {print $0}' $SOURCEFILE | awk '{if($0 ~ /[[:digit:]]/ && $0 !~ /\+/ && NF == 3){print $0}}' > $SUCTIONSIDE

	  awk 'FNR==NR{pressure[FNR]=$0;next}{suctionside[FNR]=$0};END{ for(i=0;i<FNR;i++){print pressure[i],suctionside[i]}}' $PRESSURESIDE $SUCTIONSIDE | awk '{ if($2 !~ /[[:digit:]]/ && NR > 2){ print "#SECTION ",$3}else if($2 ~ /[[:digit:]]/ && NR > 5){print $0} }' > $NEWNAME

#	  awk 'FNR==NR{pressure[FNR]=$0;next}{suctionside[FNR]=$0};END{ secidx=10; for(i=0;i<FNR;i++) { \
#	  if(i==secidx) \
#	  { \
#			 for(sec_i=secidx;sec_i > 0;sec_i--) \
#			 {\
#					print suctionside[sec_i]; \
#			 } \
#	  } \
#	  if(pressure[i] ~ /section/i && pressure[i] == suctionside[i]) \
#	  { \
#			 moveidx=pressure[i+1]; \
#			 secidx=i+moveidx+1; \
#	  } \
#	  if(pressure[i] ~ /[[:digit:]]/ && pressure[i] !~ /[+]/) \
#	  { \
#			 print pressure[i]; \
#	  } } }' $PRESSURESIDE $SUCTIONSIDE > $NEWNAME
#	  awk 'BEGIN{};FNR==NR{pressureside[NR]=$0;next}{print $0, pressureside[FNR]};END{print FNR, NR}'  $PRESSURESIDE $SUCTIONSIDE > $NEWNAME

#	  awk 'BEGIN{idx=0;cnt=0}FNR==NR{if($1 ~ /[[:digit:]]/ && $2 ~ /[[:digit:]]/ && $3 ~ /[[:digit:]]/ && $1 !~ /[+0-9]/){ data[cnt]= $0; cnt++}; next}{print $0, data[cnt]};END{print cnt,idx}'  $PRESSURESIDE $SUCTIONSIDE > $NEWNAME

#	  awk '{if($1 ~ /section/){ print $0}else if(   }	 if($0 ~ /section/i){idx++;}else  

#	  awk '/SUCTION/i,/PRESSURE/i { if ($1 ~ /[[:digit:]]/ && $2 ~ /[[:digit:]]/ && $3 ~ /[[:digit:]]/ && $1 !~ /[+2]/){print $1,$2,$3} }' $SOURCEFILE > $NEWNAME #else if( $0 ~ /section/){ print $0;}
#	  awk '/PRESSURE/i,G { if ($1 ~ /[[:digit:]]/ && $2 ~ /[[:digit:]]/ && $3 ~ /[[:digit:]]/ && $1 !~ /[+2]/){print $1,$2,$3}}' $SOURCFILE | tac >> $NEWNAME #else if( $0 ~ /section/){ print $0;}

#	  awk -v FILENM=$NEWNAME -v DIRNAME=$SRCDIR -v PROFILENAME=$NAME '{ if( /TURBODIRNAME/) { sub(/TURBODIRNAME/,DIRNAME,$0); print } \
#																				   else if( /FILENAME/) { sub(/FILENAME/,FILENM,$0); print }  \
#																				   else if ( /PROFILE/) { sub(/PROFILE/,PROFILENAME,$0); print } \
#																				   else { print $0 } }' $GNPL_FILETMPL > $GNPLNEWNAME
	  
#	  if [[ -f $GNPLNEWNAME &&  -f /usr/bin/gnuplot ]]; then
#			 /usr/bin/gnuplot $GNPLNEWNAME
#			 echo "$NAME DONE. GRAPHS GENERATED"
			 
#			 if [ $? -eq 0 ]; then
#					rm $PRESSURESIDE $SUCTIONSIDE
#			 fi
#	  fi

fi
	 

	  
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


