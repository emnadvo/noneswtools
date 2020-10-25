#!/bin/bash
#:
#

declare LOGFORMAT="%s|%s| %s |%s\n"
declare DIVIDE="===================================\n"
declare ACTUAL_DIR=$(pwd)
declare LOG_FILE=$ACTUAL_DIR/"solve_resulting.log"
declare STATUS="INFO"
declare MSG
declare TODAY=$(date '+%d.%m.%Y %H:%M:%S')
declare -a SCRPROPERTY
declare ARRAYSIZE=0
declare OUTPUTFILE=$ACTUAL_DIR/"extracting_data.dat"

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


RESULT_DIR[0]='/mnt/data4/cfd/WORK/2014/2014_018_LBk_035_0680_035_194_exp_CFX/SOLUTION/Numeca/Re00250e3_Ma080_i000_Re00250e3_Ma02_SST'
RESULT_DIR[1]='/home/mnadvornik/DATA4/WORK/2014/2014_024_2DProfiles_CFXvsNumeca/SOLUTION/LBk_035_0880_140_148_exp_tip/SOLUTION/Ma04/Re00250e3_Ma040_i000/Re00250e3_Ma040_i000_Re00250e3_Ma02_SA'
RESULT_DIR[2]='/home/mnadvornik/DATA4/WORK/2014/2014_024_2DProfiles_CFXvsNumeca/SOLUTION/LBk_035_0880_140_148_exp_tip/SOLUTION/Ma04/Re00250e3_Ma040_i000/Re00250e3_Ma040_i000_Re00250e3_Ma02_SST'
RESULT_DIR[3]='/home/mnadvornik/DATA4/WORK/2014/2014_024_2DProfiles_CFXvsNumeca/SOLUTION/LBk_035_0880_140_148_exp_tip/SOLUTION/Ma08/Re00250e3_Ma080_i000/Re00250e3_Ma080_i000_Re00250e3_Ma02_SA'
RESULT_DIR[4]='/home/mnadvornik/DATA4/WORK/2014/2014_024_2DProfiles_CFXvsNumeca/SOLUTION/LBk_035_0880_140_148_exp_tip/SOLUTION/Ma08/Re00250e3_Ma080_i000/Re00250e3_Ma080_i000_Re00250e3_Ma02_SST'
RESULT_DIR[5]='/home/mnadvornik/DATA4/WORK/2014/2014_024_2DProfiles_CFXvsNumeca/SOLUTION/LBk_035_0780_075_171_exp_mid/SOLUTION/Re00250e3_Ma040_i000/Re00250e3_Ma040_i000_Re00250e3_Ma02_SA'
RESULT_DIR[6]='/home/mnadvornik/DATA4/WORK/2014/2014_024_2DProfiles_CFXvsNumeca/SOLUTION/LBk_035_0780_075_171_exp_mid/SOLUTION/Re00250e3_Ma040_i000/Re00250e3_Ma040_i000_Re00250e3_Ma02_SST'
RESULT_DIR[7]='/home/mnadvornik/DATA4/WORK/2014/2014_024_2DProfiles_CFXvsNumeca/SOLUTION/LBk_035_0780_075_171_exp_mid/SOLUTION/Re00250e3_Ma080_i000/Re00250e3_Ma080_i000_Re00250e3_Ma02_SA'
RESULT_DIR[8]='/home/mnadvornik/DATA4/WORK/2014/2014_024_2DProfiles_CFXvsNumeca/SOLUTION/LBk_035_0780_075_171_exp_mid/SOLUTION/Re00250e3_Ma080_i000/Re00250e3_Ma080_i000_Re00250e3_Ma02_SST'
RESULT_DIR[9]='/home/mnadvornik/DATA4/WORK/2014/2014_024_2DProfiles_CFXvsNumeca/SOLUTION/018_LBk_035_0680_035_194_exp_CFX_hub/SOLUTION/Numeca/Re00250e3_Ma040_i000_Re00250e3_Ma02_SA'
RESULT_DIR[10]='/home/mnadvornik/DATA4/WORK/2014/2014_024_2DProfiles_CFXvsNumeca/SOLUTION/018_LBk_035_0680_035_194_exp_CFX_hub/SOLUTION/Numeca/Re00250e3_Ma040_i000_SST'
RESULT_DIR[11]='/home/mnadvornik/DATA4/WORK/2014/2014_024_2DProfiles_CFXvsNumeca/SOLUTION/018_LBk_035_0680_035_194_exp_CFX_hub/SOLUTION/Numeca/Re00250e3_Ma080_i000_Re00250e3_Ma02_EARSM'
RESULT_DIR[12]='/home/mnadvornik/DATA4/WORK/2014/2014_024_2DProfiles_CFXvsNumeca/SOLUTION/018_LBk_035_0680_035_194_exp_CFX_hub/SOLUTION/Numeca/Re00250e3_Ma080_i000_Re00250e3_Ma02_SST'
RESULT_DIR[13]='/home/mnadvornik/DATA4/WORK/2014/2014_024_2DProfiles_CFXvsNumeca/SOLUTION/019_LBk_035_0680_035_254_exp_CFX_hub/SOLUTION/Calculation/Numeca/Re00250e3_Ma040_i000_Re00250e3_Ma02_meshB_SA'
RESULT_DIR[14]='/home/mnadvornik/DATA4/WORK/2014/2014_024_2DProfiles_CFXvsNumeca/SOLUTION/019_LBk_035_0680_035_254_exp_CFX_hub/SOLUTION/Calculation/Numeca/Re00250e3_Ma040_i000_Re00250e3_Ma02_meshB_SST'
RESULT_DIR[15]='/home/mnadvornik/DATA4/WORK/2014/2014_024_2DProfiles_CFXvsNumeca/SOLUTION/019_LBk_035_0680_035_254_exp_CFX_hub/SOLUTION/Calculation/Numeca/Re00250e3_Ma080_i000_Re00250e3_Ma02_meshB_SA'
RESULT_DIR[16]='/home/mnadvornik/DATA4/WORK/2014/2014_024_2DProfiles_CFXvsNumeca/SOLUTION/019_LBk_035_0680_035_254_exp_CFX_hub/SOLUTION/Calculation/Numeca/Re00250e3_Ma080_i000_Re00250e3_Ma02_meshB_SST'
RESULT_DIR[17]='/home/mnadvornik/DATA4/WORK/2014/2014_017_2DProfiles_LBk_mid_Numeca/SOLUTION/2014_009_LBk_035_0780_075_171_exp/Results/LBk_035_0780_075_171_exp/Re00250e3_Ma040_i000'
RESULT_DIR[18]='/home/mnadvornik/DATA4/WORK/2014/2014_017_2DProfiles_LBk_mid_Numeca/SOLUTION/2014_009_LBk_035_0780_075_171_exp/Results/LBk_035_0780_075_171_exp/Re00250e3_Ma080_i000'
RESULT_DIR[19]='/mnt/data3/cfd/WORK/2014/2014_012_SPW_2DProfiles_Lbk_hub_Numeca/SOLUTION/2014_009_LBk_035_0680_035_194_exp/Results/LBk_035_0680_035_194_exp/Re00250e3_Ma040_i000'
RESULT_DIR[19]='/mnt/data3/cfd/WORK/2014/2014_012_SPW_2DProfiles_Lbk_hub_Numeca/SOLUTION/2014_009_LBk_035_0680_035_194_exp/Results/LBk_035_0680_035_194_exp/Re00250e3_Ma080_i000'
RESULT_DIR[20]='/mnt/data3/cfd/WORK/2014/2014_012_SPW_2DProfiles_Lbk_hub_Numeca/SOLUTION/2014_010_LBk_035_0680_035_254_exp/Results/Re00250e3_Ma040_i000_SST'
RESULT_DIR[21]='/mnt/data3/cfd/WORK/2014/2014_012_SPW_2DProfiles_Lbk_hub_Numeca/SOLUTION/2014_010_LBk_035_0680_035_254_exp/Results/LBk_035_0680_035_254_exp/Re00250e3_Ma040_i000'
RESULT_DIR[22]='/mnt/data3/cfd/WORK/2014/2014_012_SPW_2DProfiles_Lbk_hub_Numeca/SOLUTION/2014_010_LBk_035_0680_035_254_exp/Results/LBk_035_0680_035_254_exp/Re00250e3_Ma080_i000'
RESULT_DIR[23]='/mnt/data3/cfd/WORK/2014/2014_015_2DProfiles_LBk_tip_Numeca/SOLUTION/2014_009_LBk_035_0880_140_148_exp/Results/LBk_035_0880_140_148_exp/Re00250e3_Ma040_i000'
RESULT_DIR[24]='/mnt/data3/cfd/WORK/2014/2014_015_2DProfiles_LBk_tip_Numeca/SOLUTION/2014_009_LBk_035_0880_140_148_exp/Results/LBk_035_0880_140_148_exp/Re00250e3_Ma080_i000'

LogMsg $STATUS "------ SCRIPT solve_resulting STARTED ------"

#debug flag start
#set -x

#debug flag stop
#set +x
if [ -f $OUTPUTFILE ]; then
	  rm -v $OUTPUTFILE
fi

for RESDIR in "${RESULT_DIR[@]}"
do

if [ ! -d $RESDIR ]
then
	  echo "Results dir don\'t exist!\nCheck directory setting.\n"
	  exit 1
fi

for RESFILE in $(find "$RESDIR" -type f -regex ".*/data_results.*/.*ave.*" 2>>$LOG_FILE )
do
	  printf "EXECUTE FILE: %s\n" "$RESFILE"
	  printf "RESULT FILE: %s\n" "$RESFILE" >> $OUTPUTFILE
	  tail -n 10 $RESFILE | head -n 1 >> $OUTPUTFILE
	  printf "\n\n" >> $OUTPUTFILE
done

done

exit 0
