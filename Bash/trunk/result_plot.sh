#!/bin/bash
#:
#: Title			: result_plot.sh
#: Date			: 10.02.2011 15:23:58
#: Version		: 1.0
#: Developer	: mnadvornik
#: Description	: Plot any property from msteam result file.
#: Options		: 
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
declare LOGFORMAT="%s|%s| %s |%s\n"
declare DIVIDE="===================================\n"
declare ACTUAL_DIR=$(pwd)
declare LOG_FILE="result_plot.log"
declare STATUS="INFO"
declare MSG
declare TODAY=$(date '+%d.%m.%Y %H:%M:%S')
declare SCRIPTCFG="$HOME/Data/result_plot.cfg"
declare -a SCRPROPERTY
declare ARRAYSIZE=0
declare DATAFILE=plot_data.dat
declare PLTFILE=plotting.gnpl
declare OUTPNGDIR=PNGOut


#Function for logging any messages
function LogMsg {
	  TODAY=$(date '+%d.%m.%Y %H:%M:%S')
	  if [ ! -f $ACTUAL_DIR/$LOG_FILE ]
	  then
			 printf "$LOGFORMAT" "$TODAY" "$USER" "$1" "$2" > $ACTUAL_DIR/$LOG_FILE
	  else
			 printf "$LOGFORMAT" "$TODAY" "$USER" "$1" "$2" >> $ACTUAL_DIR/$LOG_FILE
			  fi
}

#Function for logging end script
function LogEnd {
	  LogMsg "END" "Script ended correctly!"
	  printf $DIVIDE >> $LOG_FILE
}

#Function for reading property from any cfg file
function CfgRead {
	  if [ -f $SCRIPTCFG ] 
	  then	  
			 MSG="READ DATA FROM CONFIG FILE START "$SCRIPTCFG
			 LogMsg $STATUS "$MSG"
			 a=0
			 while read line
			 do
				SCRPROPERTY[a]=$line
				a=$(($a+1))
			 done < $SCRIPTCFG
			 MSG=("END READ SECTION FROM FILE "$SCRIPTCFG" - OK")
			 echo $MSG
			 LogMsg $STATUS "$MSG"
 			 ARRAYSIZE=$(($a))
	  fi
}

#Function for prepare plotting data into plot_data.dat file
function Plotting {
			 MSG="PLOTING START "
			 LogMsg $STATUS "$MSG"
	  
			 declare -a OUT_DATA
	  
			 #zdrojovy adresar
			 cd ${SCRPROPERTY[0]}
			 pwd
			 #zdrojovy soubor
			 SOURCE_FILE=${SCRPROPERTY[1]}
			 MAXITER=$(tail --lines=1 $SOURCE_FILE | cut -f 1 | awk '{printf $1}' 2>>$ACTUAL_DIR/$LOG_FILE)

			 #Vsechny polozky nacist a vytvorit datovy soubor
			 i=2
			 while [ $i -ne $ARRAYSIZE ]
			 do

					declare -a DATA
					declare MAXSIZE=0
					DATASOURCE=${SCRPROPERTY[$i]}
					b=0
					# vyhleda radky obsahujici text v promenne DATASOURCE -> cfg file a nacte vsechny cisla
					for q in $(grep -i "$DATASOURCE" $SOURCE_FILE | cut -s -d \= -f 2 | cut -c 1-15 2>>$ACTUAL_DIR/$LOG_FILE)
					do 
						  DATA[b]=$q
						  b=$(($b+1))
					done

					MAXSIZE=$b
					let UNIT=$MAXITER/$MAXSIZE

					p=0
					iter=$UNIT

					# ulozi extrahovane data do vysledne matice
					while [ $p -ne $MAXSIZE ]
					do
						  if [ $i -eq 2 ]
						  then
								 OUT_DATA[p]=$(echo $iter' '${DATA[p]})
						  else
								 OUT_DATA[p]=$(echo ${OUT_DATA[p]}' '${DATA[p]})
						  fi
						  let iter=($iter+$UNIT)
						  p=$(($p+1))
					done

			 i=$(($i+1))
			 let MAXCOLUMN=$i-2

			 done
			
			 if [ ! -d $OUTPNGDIR ]
			 then
					mkdir $OUTPNGDIR
			 fi

			 p=1
			 echo ${OUT_DATA[0]} > $OUTPNGDIR/$DATAFILE
			 while [ $p -ne $MAXSIZE ]
			 do
					echo ${OUT_DATA[p]} >> $OUTPNGDIR/$DATAFILE
					p=$(($p+1))
			 done

			 MSG="PLOTING STOPED CORRECTLY."
			 LogMsg $STATUS "$MSG"	  
}

###############################################################################################
# MAIN ACTION PART
###############################################################################################

LogMsg $STATUS "------ SCRIPT result_plot.sh STARTED ------"

CfgRead

case "$1" in
	  start)
			 Plotting
#			Generate source file for gnuplot			 
			 echo 'set grid' > $OUTPNGDIR/$PLTFILE
			 echo 'set autoscale' >> $OUTPNGDIR/$PLTFILE
			 echo 'set terminal png' >> $OUTPNGDIR/$PLTFILE
			 echo '' >> $OUTPNGDIR/$PLTFILE
			 i=2
			 while [ $i -ne $(($MAXCOLUMN+2)) ]
			 do
			 echo 'set output "'$OUTPNGDIR/${SCRPROPERTY[$i]}'.png"' >> $OUTPNGDIR/$PLTFILE
			 echo 'plot "'$OUTPNGDIR/$DATAFILE'" using 1:'$i' with linespoints pointtype 7 title "'${SCRPROPERTY[$i]}'"' >> $OUTPNGDIR/$PLTFILE
					i=$(($i+1))
			 echo '' >> $OUTPNGDIR/$PLTFILE
			 done

			 echo 'set terminal x11' >> $OUTPNGDIR/$PLTFILE

			 gnuplot $OUTPNGDIR/$PLTFILE 2>>$ACTUAL_DIR/$LOG_FILE

			 cd $ACTUAL_DIR
	  ;;
	  archive)
	  ;;
	  archive|start)
	  ;;
	  verbose)
			 echo ${SCRPROPERTY[*]}
	  ;;
	  *) echo 'UNKNOWN OPERATION! YOU MUST USE PARAMS START|ARCHIVE'
esac	  
	  
LogEnd
