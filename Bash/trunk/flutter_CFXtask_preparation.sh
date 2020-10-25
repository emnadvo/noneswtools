#!/bin/bash
#:
#: Title			: mode_bc_preparation.sh
#: Date			: 23.06.2014 09:27:57
#: Version		: 1.0
#: Developer	: mnadvornik
#: Description	: Script for prepare mode file for flutter analyse.
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

#declare TEMPL="/mnt/data3/cfd/WORK/2014/2014_029_SPWR_Modul5_L-0_flutter/SETTINGS/M5_mode1_1p_templ.csv"
declare HEAD="[Name],,,,,,,,
mode1,,,,,,,,
,,,,,,,,
[Parameters],,,,,,,,"
declare TAIL=",,,,,,,,
[Spatial Fields],,,,,,,,
Initial X, Initial Y, Initial Z,,,,,,
,,,,,,,,
[Data],,,,,,,,
Initial X [ mm ], Initial Y [ mm ], Initial Z [ mm ], meshdisptot x [ mm ], meshdisptot y [ mm ], meshdisptot z [ mm ],Imaginary meshdisptot x [ mm ],Imaginary meshdisptot y [ mm ],Imaginary meshdisptot z [ mm ]"

declare PRETEMPL=/windows/D/Codes/noneswtools/Bash/trunk/transform_profile_data.pre
declare CFXBINDIR=/opt/sw/ansys_inc-15/v150/CFX/bin
declare AWKSCRIPT=/windows/D/Codes/noneswtools/Bash/trunk/CFX_def_file_change.awk

# Nutno zmenit adresar s vlastnimi tvary, popr. zdrojovy soubor pro vygenerovani def souboru a souboru pro zmeny ND
declare NODEDIR=/mnt/data3/cfd/WORK/2014/2014_029_SPWR_Modul5_L-0_flutter/SETTINGS/Node/Freq2
declare DEFFILETEMPL=/mnt/data3/cfd/WORK/2014/2014_029_SPWR_Modul5_L-0_flutter/SOLUTION/Calculation/M5_nonstationar_DPWR_flutter_stage_ND1.nfo
declare DEFSOURCEFILE=/mnt/data3/cfd/WORK/2014/2014_029_SPWR_Modul5_L-0_flutter/SOLUTION/Calculation/M5_nonstationar_DPWR_flutter_stage_ND1.def

# Zadat sablonu jmena a pocet lopatek
declare TEMPLNAME="M5_mode2_ND"
declare BLADECOUNT=64


declare NEWPREFILENAME=$NODEDIR/$TEMPLNAME"transform.pre"
awk 'NR < 8 {print $0}' $PRETEMPL > $NEWPREFILENAME

for ITEM in `find $NODEDIR -type f -name '*.freq' | sort`
do 
	  MAXDISPL=`/opt/sw/MATLAB/R2011a/bin/matlab -nosplash -nodesktop -nodisplay -r "addpath('/windows/D/Codes/noneswtools/MFiles/trunk'),sprintf('Maximum Displacement = %.5f [mm],,,,,,,,',get_maxdisplacement_fromFile('$ITEM')),exit" | grep 'Maxim.*Displa.*'`
	  NAME=`basename $ITEM | cut -d \. -f 1`
	  DIR=`dirname $ITEM`
	  NODALDIAMETER=`awk '$0 ~ /HI/ {print $7}' $ITEM | sed "s/\.//"`
	  FREQUENCY=`awk '$0 ~ /Frequency/ {print $5}' $ITEM`
	  KINENERGY=`awk '$0 ~ /Kinetic.energy/ {print sqrt($5**2+$8**2)}' $ITEM`
	  OUTNAME=$DIR/$TEMPLNAME$NODALDIAMETER".csv"
	  #echo $OUTNAME

	  #insert head	  
	  printf "%s\n" "$HEAD" > $OUTNAME

	  #insert parameters  
	  printf "Frequency = %s [Hz],,,,,,,,\n" "$FREQUENCY" >> $OUTNAME
	  printf "%s\n" "$MAXDISPL" >> $OUTNAME

	  #insert tail
	  printf "%s\n" "$TAIL" >> $OUTNAME

	  awk 'NR >= 4 { print $3,",",$2,",",$1,",",$6,",",$5,",",$4,",",$9,",",$8,",",$7 }' $ITEM >> $OUTNAME

	  echo "FILE WITH NAME $OUTNAME WAS CREATED."

	  #End section
	  wait ${!}

## Transform mode from 1 blade to all blades
	  NEWFILE=$DIR/$TEMPLNAME$NODALDIAMETER"_"$BLADECOUNT".csv"
	  awk -v OLDFILE=$OUTNAME -v NEWFILE=$NEWFILE -v BLADECNT=$BLADECOUNT 'NR >= 8 { if($0 ~ /ProfileName/) {  sub(/OLDPRFILE/,OLDFILE,$0); print } \
																							  else if($0 ~ /ComponentsIn360/) { sub(/CMPTNNUMB/,BLADECNT,$0); print  } \
																							  else if($0 ~ /NewProfileDataPath/) { sub(/NEWPRFILE/,NEWFILE,$0); print } \
																							  else {print $0} } ' $PRETEMPL >> $NEWPREFILENAME

	  echo "MODE $NAME WAS APPEND TO BASE SCRIPT"
	  printf "\n\n" >> $NEWPREFILENAME

	  #End section
	  wait ${!}

## Generate file with changes for .def file - positive ND
	  DEF_NEW_NAME=$(dirname $DEFFILETEMPL)/$TEMPLNAME$NODALDIAMETER
	  #echo $DEF_NEW_NAME

	  NEWDEF=$DEF_NEW_NAME".def"	  

	  awk -f $AWKSCRIPT -v IN_MODEFILE=$NEWFILE -v IN_NDIAM=$NODALDIAMETER -v IN_FREQ=$FREQUENCY -v IN_NEWRESFILE=$NEWDEF $DEFFILETEMPL > $DEF_NEW_NAME".dat"
	  echo "SCRIPT $DEF_NEW_NAME WAS CREATED OK"

	  if [[ $? -eq 0 && -f $DEF_NEW_NAME".dat" ]]; then
			 echo "SCRIPT $DEF_NEW_NAME.def GENERATION START..."
			 cp $DEFSOURCEFILE $NEWDEF 2>&1
			 $CFXBINDIR/cfx5cmds -write -def $NEWDEF -text $DEF_NEW_NAME".dat" 2>&1
			 echo "SCRIPT $DEF_NEW_NAME.def WAS GENERATED." 
	  fi

	  #End section
	  wait ${!}

	  if [ $NODALDIAMETER -ne 0 ]; then
	  ## Generate file with changes for .def file - negative ND
			 NEGDEF_NEW_NAME=$(dirname $DEFFILETEMPL)/$TEMPLNAME"-"$NODALDIAMETER
			 #echo $DEF_NEW_NAME
	  
			 NEWDEF=$NEGDEF_NEW_NAME".def"

			 awk -f $AWKSCRIPT -v IN_MODEFILE=$NEWFILE -v IN_NDIAM=$(expr $NODALDIAMETER \* \-1) -v IN_FREQ=$FREQUENCY -v IN_NEWRESFILE=$NEWDEF $DEFFILETEMPL > $NEGDEF_NEW_NAME".dat"
			 echo "SCRIPT $NEGDEF_NEW_NAM WAS CREATED OK"	  

			 if [[ $? -eq 0 && -f $NEGDEF_NEW_NAME".dat" ]]; then
					echo "SCRIPT $NEGDEF_NEW_NAME.def GENERATION START..."					
					cp $DEFSOURCEFILE $NEWDEF 2>&1
					#$CFXBINDIR/cfx5cmds -write -def $NEWDEF -text $NEGDEF_NEW_NAME".dat" 2>&1
					echo "SCRIPT $NEGDEF_NEW_NAME.def WAS GENERATED." 
			 fi

			 #End section
			 wait ${!}
	  fi

done

if [[ $? -eq 0 && -f $NEWPREFILENAME ]]; then
	  echo "BASE SCRIPT $NEWPREFILENAME EXECUTE START"
#	  $CFXBINDIR/cfx5pre -batch $NEWPREFILENAME 1>>$LOG_FILE 2>&1

	  if [ $? -eq 0 ]; then
			 rm -f $NEWPREFILENAME 2>&1
	  fi
fi

#End section
wait ${!}

echo "SCRIPT ENDED"

#$DEFFILETEMPL
