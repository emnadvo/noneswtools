#!/bin/bash
#:

export CFX_TSETOOLS_DIR='/opt/sw/ansys_inc-15/v150/CFD-Post/tools/tseUtils/v8.3'; 
export CFXPOST_USER_MACROS="$CFX_TSETOOLS_DIR/tseTurbineReport.cse, $CFX_TSETOOLS_DIR/numecaCgnsConverter.cse, $CFX_TSETOOLS_DIR/createCfdVars.cse";

declare RESDIR=/mnt/data3/cfd/WORK/2014/2014_047_SPW_Naantali_ST1_Numeca/solution/2014_047_Naatali_ST1/2014_047_Naatali_ST1_new_computation_1
#declare RESDIR=/home/mnadvornik/NDAT/ReactSL
declare CONVERTBIN="$CFX_TSETOOLS_DIR/"bin/converter
declare CSETEMPL_ROWS=/windows/D/Codes/Ansys_templ/numeca_ReactSL_template_rows.cse
declare CSETEMPL_ZONES=/windows/D/Codes/Ansys_templ/numeca_ReactSL_template_zones.cse
#declare REGEXP=".*/sol.*/.*/lD.*/.*_NS.cgns"
#declare REGEXP=".*compu.*[0-9].cgns"
declare REGEXP=".*.cgns"
declare CFXBIN=/opt/sw/ansys_inc-15/v150/CFD-Post/bin/cfdpost
declare CSETEMPL=/windows/D/Codes/Ansys_templ/Stage3D_Numeca_defaultMesh_templ.cse

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
	  REGEXP='.*convert.cgns'
	  for ITEM in `find $RESDIR -type f -regex $REGEXP -printf "%p\n"`
	  do
			 printf "FILE %s EVALUATE NOW.\n" "$ITEM"

			 DIRNAME=`dirname $ITEM`
			 cd $DIRNAME

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
