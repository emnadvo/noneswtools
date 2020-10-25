#!/bin/sh
#set -x

B=$(tput bold)
N=$(tput sgr0)

# Grid Engine will automatically start/stop this script on exec hosts, if
# configured properly. See the application note for configuration
# instructions or contact support@gridware.com
# fs to check
FS=/tmp

if [ "$SGE_ROOT" != "" ]; then
   root_dir=$SGE_ROOT
fi

# invariant values
#myarch=`$root_dir/util/arch`
#myhost=`$root_dir/utilbin/$myarch/gethostname -name`

# ----------------------------------------------------
# Prikazy pro zpracovani textu		AWK  SED
# ----------------------------------------------------
AWK=/usr/bin/awk
SED=/usr/bin/sed
GREP=/usr/bin/grep

# ----------------------------------------------------
# Prikaz pro vyvolani stavu licence
#   o vstupnim argumentem je volani licencni serveru
#   o vystup je v podobe:
# ----------------------------------------------------
#	lmutil - Copyright (c) 1989-2012 Flexera Software LLC. All Rights Reserved.
#	Flexible License Manager status on Sun 3/30/2014 17:53
#
#	License server status: 1055@pwrs-lic02.corp.doosan.com
#	License file(s) on pwrs-lic02.corp.doosan.com: 
#		C:\Program Files\ANSYS Inc\Shared Files\Licensing\license.dat:
#
#	pwrs-lic02.corp.doosan.com: license server UP (MASTER) v11.11
#	Vendor daemon status (on pwrs-lic02.corp.doosan.com):
#		ansyslmd: UP v11.11
#
#	Feature usage info:
#	Users of ansys:  (Total of 4 licenses issued;  Total of 2 licenses in use)
#	Users of prfnls:  (Total of 1 license issued;  Total of 1 license in use)
#	Users of preppost:  (Total of 3 licenses issued;  Total of 0 licenses in use)
#	Users of picatv5:  (Total of 2 licenses issued;  Total of 0 licenses in use)
#	Users of acfd:  (Total of 2 licenses issued;  Total of 0 licenses in use)
#	Users of anshpc_pack:  (Total of 18 licenses issued;  Total of 1 license in use)
#	Users of amesh_extended:  (Total of 2 licenses issued;  Total of 1 license in use)
#	Users of acfd_preppost:  (Total of 9 licenses issued;  Total of 5 licenses in use)
#	Users of acfd_solver:  (Total of 5 licenses issued;  Total of 1 license in use)
#	Users of acfx_pre:  (Total of 5 licenses issued;  Total of 0 licenses in use)
#	Users of acfx_turbogrid:  (Total of 1 license issued;  Total of 0 licenses in use)
#	Users of agppi:  (Total of 1 license issued;  Total of 0 licenses in use)
#	Users of acfd_fluent:  (Total of 2 licenses issued;  Total of 0 licenses in use)
#
# ----------------------------------------------------
LMUTIL_CMD="/opt/sw/skoda/bin/lmutil lmstat -a -c"
ANSYS_LIC_SRV="1055@pwrs-lic02.corp.doosan.com"

# ----------------------------------------------------
# Pocet tiketu/licenci pro CFX solver
# a ANSYS HPC Pack.
# Tyto hodnoty mohou byt v tomto skriptu na pevno
# zadany, nebo je mozne je volat z lmutil
# Hodnoty jsou ziskany z prikazu:
#    /opt/sw/skoda/bin/lmutil lmstat -a -c 1055@pwrs-lic02.corp.doosan.com
#
#    a pote nalez klicova slova: 
#			acfd_solver, 
#			anshpc_pack, 
#			acfd
# ----------------------------------------------------
TICKETS_CFX_SOLVER_TOTAL=4
TICKETS_CFX_SOLVER_ADDED=""
TICKETS_ANSYS_HPC_PACK_TOTAL=18

while :
do

    # ----------------------------------------------------------------------------------------------------------- TOTAL ---
    TICKETS_ANSYS_HPC_PACK_TOTAL=$( ${LMUTIL_CMD} ${ANSYS_LIC_SRV} | ${GREP} anshpc_pack | ${AWK} '{print $6}' )
 	TICKETS_FLU_SOLVER1_TOTAL=$(    ${LMUTIL_CMD} ${ANSYS_LIC_SRV} | ${GREP} acfd_solver | ${AWK} '{print $6}' )
 	TICKETS_FLU_SOLVER2_TOTAL=$(    ${LMUTIL_CMD} ${ANSYS_LIC_SRV} | ${GREP} "acfd:"     | ${AWK} '{print $6}' )
 	TICKETS_FLU_SOLVER3_TOTAL=$(    ${LMUTIL_CMD} ${ANSYS_LIC_SRV} | ${GREP} acfd_fluent | ${AWK} '{print $6}' )

    # ------------------------------------------------------------------------------------------------------------ USED ---

	TICKETS_ANSYS_HPC_PACK_USED=$( ${LMUTIL_CMD} ${ANSYS_LIC_SRV} | ${GREP} anshpc_pack | ${AWK} '{print $11}' )
 	TICKETS_FLU_SOLVER1_USED=$(    ${LMUTIL_CMD} ${ANSYS_LIC_SRV} | ${GREP} acfd_solver | ${AWK} '{print $11}' )
 	TICKETS_FLU_SOLVER2_USED=$(    ${LMUTIL_CMD} ${ANSYS_LIC_SRV} | ${GREP} "acfd:"     | ${AWK} '{print $11}' )
 	TICKETS_FLU_SOLVER3_USED=$(    ${LMUTIL_CMD} ${ANSYS_LIC_SRV} | ${GREP} acfd_fluent | ${AWK} '{print $11}' )

    # ------------------------------------------------------------------------------------------------------- AVAILABLE ---

	TICKETS_ANSYS_HPC_PACK_AVAILABLE=$( expr ${TICKETS_ANSYS_HPC_PACK_TOTAL} - ${TICKETS_ANSYS_HPC_PACK_USED} )
 	TICKETS_FLU_SOLVER1_AVAILABLE=$(    expr ${TICKETS_FLU_SOLVER1_TOTAL} - ${TICKETS_FLU_SOLVER1_USED} )
 	TICKETS_FLU_SOLVER2_AVAILABLE=$(    expr ${TICKETS_FLU_SOLVER3_TOTAL} - ${TICKETS_FLU_SOLVER3_USED} )
 	TICKETS_FLU_SOLVER3_AVAILABLE=$(    expr ${TICKETS_FLU_SOLVER3_TOTAL} - ${TICKETS_FLU_SOLVER3_USED} )
 	TICKETS_CFX_SOLVER_AVAILABLE=$(expr ${TICKETS_FLU_SOLVER1_AVAILABLE} + ${TICKETS_FLU_SOLVER2_AVAILABLE} + ${TICKETS_FLU_SOLVER3_AVAILABLE})

#	TICKETS_CFX_SOLVER_AVAILABLE=3
#	TICKETS_ANSYS_HPC_PACK_AVAILABLE=5


	# ----------------------------------------------------------------------------------------------------------- AVAILABLE ---
	clear
    echo "" ; echo ""
	echo "${B}              License status at the   `date +%H:%M:%S`"${N}
	echo "${B}----------------------------------------------${N}" ; sleep 0.1s
	echo "${B}  License Type     Total    Used    Available"${N}
	echo "${B}----------------------------------------------"${N}
     
	echo "    anshpc_pak:      ${TICKETS_ANSYS_HPC_PACK_TOTAL}       ${TICKETS_ANSYS_HPC_PACK_USED}       ${B}${TICKETS_ANSYS_HPC_PACK_AVAILABLE}${N}" ; sleep 0.05s
	echo "   acfd_solver:       ${TICKETS_FLU_SOLVER1_TOTAL}        ${TICKETS_FLU_SOLVER1_USED}       ${B}${TICKETS_FLU_SOLVER1_AVAILABLE}${N}" ; sleep 0.05s
	echo "          acfd:       ${TICKETS_FLU_SOLVER2_TOTAL}        ${TICKETS_FLU_SOLVER2_USED}       ${B}${TICKETS_FLU_SOLVER2_AVAILABLE}${N}" ; sleep 0.05s
	echo "   acfd_fluent:       ${TICKETS_FLU_SOLVER3_TOTAL}        ${TICKETS_FLU_SOLVER3_USED}       ${B}${TICKETS_FLU_SOLVER3_AVAILABLE}${N}" ; sleep 0.05s
	echo "----------------------------------------------"
	echo ""

	echo "${B}----------------------------------------------${N}" ; sleep 0.05s
	echo "${B}Possible scenario${N}" ; sleep 0.05s
	echo "${B}----------------------------------------------${N}" ; sleep 0.05s
	if [ "${TICKETS_CFX_SOLVER_AVAILABLE}" =  "0" ]; then 
		echo "   You can not run any JOB."
		echo "   License resources are not available."
		echo "   See the table listed above."
	fi
	
	if [ "${TICKETS_CFX_SOLVER_AVAILABLE}" =  "1" ]; then 
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "1" ];  then  echo -e "\tYou can run 1 JOB @ up to 8 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "2" ];  then  echo -e "\tYou can run 1 JOB @ up to 32 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "3" ];  then  echo -e "\tYou can run 1 JOB @ up to 128 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "4" ];  then  echo -e "\tYou can run 1 JOB @ up to 512 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" -ge "5" ]; then  echo -e "\tYou can run 1 JOB @ up to 2048 CPUs"  ; fi
	fi

	if [ "${TICKETS_CFX_SOLVER_AVAILABLE}" =  "2" ]; then 
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "1" ];  then  echo -e "\tYou can run 2 JOBs @ 4 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "2" ];  then  echo -e "\tYou can run 2 JOBs @ 16 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "3" ];  then  echo -e "\tYou can run 2 JOBs @ 64 CPUs  \n  OR\n\t 1 JOB @  128 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "4" ];  then  echo -e "\tYou can run 2 JOBs @ 256 CPUs  \n  OR\n\t 1 JOB @  512 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" -ge "5" ]; then  echo -e "\tYou can run 2 JOBs @ 1024 CPUs  \n  OR\n\t1 JOB @ 2048 CPUs"  ; fi
	fi

	if [ "${TICKETS_CFX_SOLVER_AVAILABLE}" =  "3" ]; then 
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "1" ];  then  echo -e "\tYou can run 3 JOBs @ 2 CPUs & 1x 2CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "2" ];  then  echo -e "\tYou can run 3 JOBs @ 8 CPUs  \n  OR\n\t 2 JOBS @  16 CPUs  \n  OR\n\t 1 JOB @  32C PUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "3" ];  then  echo -e "\tYou can run 3 JOBs @ 36 CPUs  \n  OR\n\t 2 JOBS @  64 CPUs  \n  OR\n\t 1 JOB @  128 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "4" ];  then  echo -e "\tYou can run 3 JOBs @ 160 CPUs  \n  OR\n\t 2 JOBS @  256 CPUs  \n  OR\n\t 1 JOB @  512 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" -ge "5" ]; then  echo -e "\tYou can run 3 JOBs @ 672 CPUs  \n  OR\n\t 2 JOBs @ 1024 CPUs  \n  OR\n\t1 JOB @ 2048 CPUs"  ; fi
	fi

	if [ "${TICKETS_CFX_SOLVER_AVAILABLE}" =  "4" ]; then 
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "1" ];   then  echo -e "\tYou can run 4 JOBs @ 4x 2 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "2" ];   then  echo -e "\tYou can run 4 JOBs @ 8 CPUs  \n  OR\n\t 3 JOBS @  8 CPUs  \n  OR\n\t 2 JOBS @  16 CPUs  \n  OR\n\t 1 JOB @  32 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "3" ];   then  echo -e "\tYou can run 4 JOBs @ 32 CPUs  \n  OR\n\t 3 JOBS @  36 CPUs  \n  OR\n\t 2 JOBS @  64 CPUs  \n  OR\n\t 1 JOB @  128 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "4" ];   then  echo -e "\tYou can run 4 JOBs @ 128 CPUs  \n  OR\n\t 3 JOBS @  160 CPUs  \n  OR\n\t 2 JOBS @  256 CPUs  \n  OR\n\t 1 JOB @  512 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" -ge "5" ]; then  echo -e "\tYou can run 4 JOBs @ 512 CPUs  \n  OR\n\t 3 JOBS @  672 CPUs  \n  OR\n\t 2 JOBS @  1024 CPUs  \n  OR\n\t 1 JOB @  2048 CPUs"  ; fi
	fi

	if [ "${TICKETS_CFX_SOLVER_AVAILABLE}" =  "5" ]; then 
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "1" ];   then  echo -e "\tYou can run 5 JOBs @ 1 CPUs  \n  OR\n\t 4 JOBS @  2 CPUs  \n  OR\n\t 3 JOBS @  2 CPUs & 1x 2CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "2" ];   then  echo -e "\tYou can run 5 JOBs @ 6 CPUs  \n  OR\n\t 4 JOBS @  8 CPUs  \n  OR\n\t 3 JOBS @  8 CPUs  \n  OR\n\t 2 JOBS @  16 CPUs  \n  OR\n\t 1 JOB @  32 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "3" ];   then  echo -e "\tYou can run 5 JOBs @ 24 CPUs  \n  OR\n\t 4 JOBS @  32 CPUs  \n  OR\n\t 3 JOBS @  36 CPUs  \n  OR\n\t 2 JOBS @  64 CPUs  \n  OR\n\t 1 JOB @  128 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "4" ];   then  echo -e "\tYou can run 5 JOBs @ 96 CPUs  \n  OR\n\t 4 JOBS @  128 CPUs  \n  OR\n\t 3 JOBS @  160 CPUs  \n  OR\n\t 2 JOBS @  256 CPUs  \n  OR\n\t 1 JOB @  512 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" -ge "5" ]; then  echo -e "\tYou can run 5 JOBs @ 400 CPUs  \n  OR\n\t 4 JOBS @  512 CPUs  \n  OR\n\t 3 JOBS @  672 CPUs  \n  OR\n\t 2 JOBS @  1024 CPUs  \n  OR\n\t 1 JOB @  2048 CPUs"  ; fi
	fi

	if [ "${TICKETS_CFX_SOLVER_AVAILABLE}" =  "6" ]; then 
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "1" ];   then  echo -e "\tYou can run 6 JOBs @ 1 CPUs  \n  OR\n\t 5 JOBS @  1 CPUs  \n  OR\n\t 4 JOBS @  2 CPUs  \n  OR\n\t 3 JOBS @  2 CPUs & 1x 2CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "2" ];   then  echo -e "\tYou can run 6 JOBs @ 5 CPUs  \n  OR\n\t 5 JOBS @  6 CPUs  \n  OR\n\t 4 JOBS @  8 CPUs  \n  OR\n\t 3 JOBS @  8 CPUs  \n  OR\n\t 2 JOBS @  16 CPUs  \n  OR\n\t 1 JOB @  32 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "3" ];   then  echo -e "\tYou can run 6 JOBs @ 16 CPUs  \n  OR\n\t 5 JOBS @  24 CPUs  \n  OR\n\t 4 JOBS @  32 CPUs  \n  OR\n\t 3 JOBS @  36 CPUs  \n  OR\n\t 2 JOBS @  64 CPUs  \n  OR\n\t 1 JOB @  128 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "4" ];   then  echo -e "\tYou can run 6 JOBs @ 80 CPUs  \n  OR\n\t 5 JOBS @  96 CPUs  \n  OR\n\t 4 JOBS @  128 CPUs  \n  OR\n\t 3 JOBS @  160 CPUs  \n  OR\n\t 2 JOBS @  256 CPUs  \n  OR\n\t 1 JOB @  512 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" -ge "5" ]; then  echo -e "\tYou can run 6 JOBs @ 336 CPUs  \n  OR\n\t 5 JOBS @  400 CPUs  \n  OR\n\t 4 JOBS @  512 CPUs  \n  OR\n\t 3 JOBS @  672 CPUs  \n  OR\n\t 2 JOBS @  1024 CPUs  \n  OR\n\t 1 JOB @  2048 CPUs"  ; fi
	fi

	if [ "${TICKETS_CFX_SOLVER_AVAILABLE}" =  "7" ]; then 
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "1" ];   then  echo -e "\tYou can run 7 JOBs @ 1 CPUs  \n  OR\n\t 6 JOBs @ 6x 1 CPUs  \n  OR\n\t 5 JOBS @  1 CPUs  \n  OR\n\t 4 JOBS @  2 CPUs  \n  OR\n\t 3 JOBS @  2 CPUs & 1x 2CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "2" ];   then  echo -e "\tYou can run 7 JOBs @ 4 CPUs  \n  OR\n\t 6 JOBS @ 5 CPUs  \n  OR\n\t 5 JOBS @  6 CPUs  \n  OR\n\t 4 JOBS @  8 CPUs  \n  OR\n\t 3 JOBS @  8 CPUs  \n  OR\n\t 2 JOBS @  16 CPUs  \n  OR\n\t 1x 32 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "3" ];   then  echo -e "\tYou can run 7 JOBs @ 16 CPUs  \n  OR\n\t 6 JOBS @ 16 CPUs  \n  OR\n\t 5 JOBS @  24 CPUs  || 4x 32 CPUs  \n  OR\n\t 3 JOBS @  36 CPUs  \n  OR\n\t 2 JOBS @  64 CPUs  \n  OR\n\t 1x 128 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "4" ];   then  echo -e "\tYou can run 7 JOBs @ 64 CPUs  \n  OR\n\t 6 JOBS @ 80 CPUs  \n  OR\n\t 5 JOBS @  96 CPUs  || 4x 128 CPUs  \n  OR\n\t 3 JOBS @  160 CPUs  \n  OR\n\t 2 JOBS @  256 CPUs  \n  OR\n\t 1x 512 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" -ge "5" ]; then  echo -e "\tYou can run 7 JOBs @ 288 CPUs  \n  OR\n\t 6 JOBS @  336 CPUs  \n  OR\n\t 5 JOBS @  400 CPUs  \n  OR\n\t 4 JOBS @  512 CPUs  \n  OR\n\t 3 JOBS @  672 CPUs  \n  OR\n\t 2 JOBS @  1024 CPUs  \n  OR\n\t 1x 2048 CPUs"  ; fi
	fi

	if [ "${TICKETS_CFX_SOLVER_AVAILABLE}" =  "8" ]; then
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "1" ];   then  echo -e "\tYou can run 8 JOBs @ 1 CPUs  \n  OR\n\t 7 JOBs @ 1 CPUs  \n  OR\n\t 6 JOBs @ 1 CPU  \n  OR\n\t 5 JOBS @  1 CPU  \n  OR\n\t 4 JOBS @  2 CPUs  \n  OR\n\t 3 JOBS @  2 CPUs & 1x 2CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "2" ];   then  echo -e "\tYou can run 8 JOBs @ 4 CPUs  \n  OR\n\t 7 JOBS @ 4 CPUs  \n  OR\n\t 6 JOBS @ 5 CPUs  \n  OR\n\t 5 JOBS @  6 CPUs  \n  OR\n\t 4 JOBS @  8 CPUs  \n  OR\n\t 3 JOBS @  8 CPUs  \n  OR\n\t 2 JOBS @  16 CPUs  \n  OR\n\t 1x 32 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "3" ];   then  echo -e "\tYou can run 8 JOBs @ 16 CPUs  \n  OR\n\t 7 JOBS @ 16 CPUs  \n  OR\n\t 6 JOBS @ 16 CPUs  \n  OR\n\t 5 JOBS @  24 CPUs  || 4x 32 CPUs  \n  OR\n\t 3 JOBS @  36 CPUs  \n  OR\n\t 2 JOBS @  64 CPUs  \n  OR\n\t 1x 128 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "4" ];   then  echo -e "\tYou can run 8 JOBs @ 64 CPUs  \n  OR\n\t 7 JOBS @ 64 CPUs  \n  OR\n\t 6 JOBS @ 80 CPUs  \n  OR\n\t 5 JOBS @  96 CPUs  || 4x 128 CPUs  \n  OR\n\t 3 JOBS @  160 CPUs  \n  OR\n\t 2 JOBS @  256 CPUs  \n  OR\n\t 1x 512 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" -ge "5" ]; then  echo -e "\tYou can run 8 JOBs @ 256 CPUs  \n  OR\n\t 7 JOBS @  288 CPUs  \n  OR\n\t 6 JOBS @  336 CPUs  \n  OR\n\t 5 JOBS @  400 CPUs  \n  OR\n\t 4 JOBS @  512 CPUs  \n  OR\n\t 3 JOBS @  672 CPUs  \n  OR\n\t 2 JOBS @  1024 CPUs  \n  OR\n\t 1x 2048 CPUs"  ; fi
	fi

	if [ "${TICKETS_CFX_SOLVER_AVAILABLE}" =  "9" ]; then
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "1" ];   then  echo -e "\tYou can run 9 JOBs @ 1 CPUs  \n  8 JOBs @ 1 CPUs  \n  OR\n\t 7 JOBs @ 1 CPUs  \n  OR\n\t 6 JOBs @ 1 CPU  \n  OR\n\t 5 JOBS @  1 CPU  \n  OR\n\t 4 JOBS @  2 CPUs  \n  OR\n\t 3 JOBS @  2 CPUs & 1x 2CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "2" ];   then  echo -e "\tYou can run 9 JOBs @ 3 CPUs  \n  OR\n\t 8 JOBs @ 4 CPUs  \n  OR\n\t 7 JOBS @ 4 CPUs  \n  OR\n\t 6 JOBS @ 5 CPUs  \n  OR\n\t 5 JOBS @  6 CPUs  \n  OR\n\t 4 JOBS @  8 CPUs  \n  OR\n\t 3 JOBS @  8 CPUs  \n  OR\n\t 2 JOBS @  16 CPUs  \n  OR\n\t 1x 32 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "3" ];   then  echo -e "\tYou can run 9 JOBs @ 12 CPUs  \n  OR\n\t 8 JOBs @ 16 CPUs  \n  OR\n\t 7 JOBS @ 16 CPUs  \n  OR\n\t 6 JOBS @ 16 CPUs  \n  OR\n\t 5 JOBS @  24 CPUs  || 4x 32 CPUs  \n  OR\n\t 3 JOBS @  36 CPUs  \n  OR\n\t 2 JOBS @  64 CPUs  \n  OR\n\t 1x 128 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" = "4" ];   then  echo -e "\tYou can run 9 JOBs @ 48 CPUs  \n  OR\n\t 8 JOBs @ 64 CPUs  \n  OR\n\t 7 JOBS @ 64 CPUs  \n  OR\n\t 6 JOBS @ 80 CPUs  \n  OR\n\t 5 JOBS @  96 CPUs  || 4x 128 CPUs  \n  OR\n\t 3 JOBS @  160 CPUs  \n  OR\n\t 2 JOBS @  256 CPUs  \n  OR\n\t 1x 512 CPUs"  ; fi
		if [ "${TICKETS_ANSYS_HPC_PACK_AVAILABLE}" -ge "5" ]; then  echo -e "\tYou can run 9 JOBs @ 224 CPUs  \n  OR\n\t 8 JOBs @ 256 CPUs  \n  OR\n\t 7 JOBS @  288 CPUs  \n  OR\n\t 6 JOBS @  336 CPUs  \n  OR\n\t 5 JOBS @  400 CPUs  \n  OR\n\t 4 JOBS @  512 CPUs  \n  OR\n\t 3 JOBS @  672 CPUs  \n  OR\n\t 2 JOBS @  1024 CPUs  \n  OR\n\t 1x 2048 CPUs"  ; fi
	fi

	sleep 5s
done

exit 0
