#!/bin/bash
#:

export CFX_TSETOOLS_DIR='/opt/sw/TseTurboTools/v9.0.3'; 
export CFXPOST_USER_MACROS="$CFX_TSETOOLS_DIR/TurboReport/src/tseTurbineReport.cse, $CFX_TSETOOLS_DIR/TurboReport/src/numecaCgnsConverter.cse, $CFX_TSETOOLS_DIR/TurboReport/src/createCfdVars.cse";

#declare RESDIR=/home/mnadvornik/DATA4/WORK/2014/2014_088_Cerro_Dominador_VT13_Numeca_MSteam/SOLUTION/Numeca/Calculation/Stage/Atacama_HP13_stage/Atacama_HP13_stage_Atacama_HP13_main
#declare RESDIR=/home/mnadvornik/EXPERIMENTS/2015/Numeca_partitionparallel/M5_ventilace_long_output_grid4_10perc_main_grid4_10perc_main
#declare RESDIR=/home/mnadvornik/DATA3/WORK/2013/2013_010_SPW_Modul7_2st/SOLUTION/calculation/2012_001_Modul7_2stages/2012_001_Modul7_2stages_main_SA
declare RESDIR=/home/mnadvornik/DATA4/WORK/2015/2015_055_SPW_Empalme_M7_60Hz/Solution/Empalme_L0/Empalme_L0_recalc_mna_localtime_2
#declare RESDIR=/home/mnadvornik/NDAT/ReactSL
declare CONVERTBIN="$CFX_TSETOOLS_DIR/"cgnsConverter/bin/converter
declare CSETEMPL_ROWS=/windows/D/Codes/Ansys_templ/numeca_ReactSL_template_rows.cse
declare CSETEMPL_ZONES=/windows/D/Codes/Ansys_templ/numeca_ReactSL_template_zones.cse
#declare REGEXP=".*/sol.*/.*/lD.*/.*_NS.cgns"
#declare REGEXP=".*.cgns"
#declare REGEXP=".*grid4.10per.*.cgns"
declare REGEXP=".*.cgns"
declare CFXBIN=/opt/sw/ansys_inc-15/v150/CFD-Post/bin/cfdpost
#declare CSETEMPL=/windows/D/Codes/Ansys_templ/Stage3D_Numeca_defaultHOH_templ_stage.cse
#declare CSETEMPL=/windows/D/Codes/Ansys_templ/Stage3D_Numeca_defaultHOH_templ.cse
declare CSETEMPL=/home/mnadvornik/EXPERIMENTS/2015/M5_2stages_withlong_output/M5_ventilace_long_output/M5_ventilace_long_output_grid4.cse


declare ACTUAL_DIR=$(pwd)
declare LOGFILE=$ACTUAL_DIR/process.log


case "$1" in
  convert)

	  cd $RESDIR

	  for ITEM in `find $RESDIR -type f -regex $REGEXP -printf "%p\n"`
	  do
			 printf "FILE %s START CONVERT...\n" "$ITEM"

			 DIRNAME=`dirname $ITEM`
			 NEWNAME=`basename $ITEM | cut -d . -f 1`

			 RUNFILE=$DIRNAME/$NEWNAME".run"
			 NEWNAME=$NEWNAME"_convert.cgns"
	  
			 if [[ -d $DIRNAME && -f $RUNFILE ]]; then

					$CONVERTBIN $ITEM $RUNFILE $DIRNAME/$NEWNAME >> $LOGFILE 2>&1
					wait ${!}

					if [[ $? -eq 0 && -f $DIRNAME/$NEWNAME ]]; then
						  printf "NEW FILE %s CREATED OK.\n" "$NEWNAME" >> $LOGFILE
					else
						  printf "NEW FILE %s NOT EXIST!\n" "$NEWNAME" >> $LOGFILE
					fi
			 fi
	  done
  ;;
  eval)
	  REGEXP='.*grid4.20per.*.convert.cgns'
	  for ITEM in `find $RESDIR -type f -regex $REGEXP -printf "%p\n"`
	  do
			 printf "FILE %s EVALUATE NOW.\n" "$ITEM"

			 DIRNAME=`dirname $ITEM`
			 cd $DIRNAME
			 
#			 echo $ITEM
			 $CFXBIN -batch $CSETEMPL $ITEM >> $LOGFILE 2>&1

			 wait ${!}

			 if [ $? -eq 0 ]; then
					printf "FILE %s EVALUATE OK.\n" "$ITEM" >> $LOGFILE 
			 else
					printf "FILE %s NOT EVALUATE!.\n" "$ITEM" >> $LOGFILE
			 fi
					
#					if [ $? -ne 0 ]; then
#						  printf "ROWS TEMPLATE DON\'T SUCCESS\nNOW TRY ZONES TEMPLATES!\n"
#						  CSETEMPL=$CSETEMPL_ZONES						  
#						  $CFXBIN -batch $CSETEMPL $DIRNAME/$NEWNAME
#						  wait ${!}
#					fi
	  done
  ;;
 *)
	  printf "SCRIPT NEED PARAMETER FOR RECOGNIZE WHAT YOU WANT\nUSE convert FOR CONVERSION OR eval FOR EVALUATION\n"
esac

#End section
wait ${!}
#LogEnd
exit 0
