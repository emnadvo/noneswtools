#!/bin/bash
#:
#: Title			: results_export.sh
#: Date			: 06.10.2011 10:37:55
#: Version		: 1.0
#: Developer	: mnadvornik
#: Description	: Script for archiving and sending to customer
#: Options		: 
#:

#LOGFORMAT="01.01.2001 10:00:01|user| INFO | Text for logging" You can change, if not like.
declare LOGFORMAT="%s|%s| %s |%s\n"
declare DIVIDE="===================================\n"
declare ACTUAL_DIR=$(dirname $(readlink -f $0))
declare LOG_FILE=$ACTUAL_DIR/"lang_coding_fix_win2utf.log"
declare STATUS="INFO"
declare MSG
declare TODAY=$(date '+%d.%m.%Y %H:%M:%S')
declare SCRIPTCFG="$ACTUAL_DIR/lang_coding_fix_win2utf.cfg"
declare -a SCRPROPERTY
declare ARRAYSIZE=0
declare RESULTSDIR
declare BLADE_NAME
declare -a ALL_ITEMS
declare CUSTOMDIRECTORY="CFD_results"


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
 			 ARRAYSIZE=${#SCRPROPERTY[*]}
	  fi
}

FIND_DIRNAME='data_results'
incement=1
id=0

ALL_ITEMS[$id]='2012/2012_057_Ucpavky_porovnani_s_Hudecek/Results/vysledna_zprava'
let id+=incement
ALL_ITEMS[$id]='2012/2012_082_TSE_Rozdelena_bandaz_exp_turb_1MW/SETTINGS/_project_info_'
let id+=incement
ALL_ITEMS[$id]='2012/2012_109_SPW_Ztrata_otoceny_proud_DTC/RESULTS/old/porovnani'
let id+=incement
ALL_ITEMS[$id]='2012/2012_109_SPW_Ztrata_otoceny_proud_DTC/RESULTS/old/porovnani'
let id+=incement
ALL_ITEMS[$id]='2012/2012_136_TSE_Parcialni_ostrik_Kuopio_Sleaford/Results/FTP_TSE/Prezentace_nenavrhovky'
let id+=incement
ALL_ITEMS[$id]='2012/2012_137_VZU_Indie_660MW/Settings/20130113_BC'
let id+=incement
ALL_ITEMS[$id]='2013/2013_001_Optimalizace_52blades_Numeca_Norimberk'
let id+=incement
ALL_ITEMS[$id]='2013/2013_008_TSE_Modul7_axvystup_IEC_Eshkol/Settings'
let id+=incement
ALL_ITEMS[$id]='2013/2013_014_SPW_Hridelove_ucpavky_brzdy/SOLUTION/Fluent'
let id+=incement
ALL_ITEMS[$id]='2013/2013_019_SPW_Ucpavky2D/Results'
let id+=incement
ALL_ITEMS[$id]='2013/2013_020_SPW_Loviisa_VT1a2_axsila/Results'
let id+=incement
ALL_ITEMS[$id]='2013/2013_021_SPW_Ztratovy_soucinitel_v_difuzoru_2D'
let id+=incement
ALL_ITEMS[$id]='2013/2013_027_TSE_Loviisa_Modul6_L-1_a_L-0/Settings'
let id+=incement
ALL_ITEMS[$id]='2013/2013_033_TSE_VZLU_turbinka'
let id+=incement
ALL_ITEMS[$id]='2013/2013_036_TSE_MRS_3D_4stg_rovnotlake_valcove/Settings'
let id+=incement
ALL_ITEMS[$id]='2013/2013_037_SPW_UcpavkovyStand_2Dmodely/Settings'
let id+=incement
ALL_ITEMS[$id]='2013/2013_039_ZCU_vypocet_prutoku_ucpavkou_Galerkinovou_metodou'
let id+=incement
ALL_ITEMS[$id]='2013/2013_042_SUP_MTD20_tvarovani_na_pate_na_bubnu'
let id+=incement
ALL_ITEMS[$id]='2013/2013_043_SPW_Chotikov_ax_difuzor'
let id+=incement
ALL_ITEMS[$id]='2013/2013_044_SPW_Tornio_2a/Settings'
let id+=incement
ALL_ITEMS[$id]='2013/2013_048_SPW_brzda_nove_reseni'
let id+=incement
ALL_ITEMS[$id]='2013/2013_063_VZU_Vartan_SmartExtr_model/Settings'
let id+=incement
ALL_ITEMS[$id]='2013/2013_073_TSE_Rozdelena_bandaz_exp_turb_1MW_nenavrhove'
let id+=incement
ALL_ITEMS[$id]='2013/2013_077_TSE_Exp_turb_1MW_stare_osazeni/SETTINGS/Banan2/Dokumenty'
let id+=incement
ALL_ITEMS[$id]='2013/2013_082_NTC_Tychy_regulacni_mezistena/Settings/_project_info_'
let id+=incement
ALL_ITEMS[$id]='2013/2013_090_VZU_3D_Vartan_SmartExtr_model/Solution'
let id+=incement
ALL_ITEMS[$id]='2013/2013_092_Novy_experiment_TR-U-2/TR-U-2_nove_mereni'
let id+=incement







###############################################################################################
# MAIN ACTION PART
###############################################################################################

LogMsg $STATUS "------ SCRIPT results_export STARTED ------"

#debug flag start
#set -x

#debug flag stop
#set +x

#CfgRead

#if [ -z "$@" ]
# then
#	  msg="NEED INPUT PARAMETER WHICH IS MAIN DIRECTORY WITH CALCULATION VARIANTS AND RESULTS."
#	  echo $msg
#	  STATUS="FATAL"
#	  LogMsg $STATUS "$msg SCRIPT FAILED!"
#	  exit 2
#fi

#RESULTSDIR=$1


for item in "${ALL_ITEMS[@]}"
do
	  find /mnt/data* -name $item -print

#prikaz pro zmenu kodovani konkretne z cp1250 na utf-8, parametr --notest je nutny pro potvrzeni zmeny, bez funguje prikaz jako test - vypise ale nezmeni nazev
convmv -r --notest -f cp1250 -t utf-8 ./


done

echo 'SCRIPT DONE'
exit 0
