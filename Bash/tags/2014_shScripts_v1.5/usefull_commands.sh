for item in `find /mnt/data3/cfd/WORK/ -type f -regex '.*RBi.*.zip'`; do cp $item /home/mnadvornik/mswin/Dokumentace/Reports/React2D/cases/Resolve/; done;

#rename files
for file in `find ./ -type f -regex '.*var.*'`; do NEWNAME=`echo $file | sed "s/var1/var3/"`; mv $file $NEWNAME; done


 for ((i=1;i<5;i++)) do name=`printf "VAR%d" "$i"`; mkdir $name;done


DATAOUTPUT='./All_stages.dat';for ITEM in `find ./ -type f -name All_Stage_Tab*`; do printf "\nResult file: %s\n" "$ITEM" >> $DATAOUTPUT; cat $ITEM >> $DATAOUTPUT; done

for ITEM in `find ./ -type f -regex '.*/.*convert.cgns' -printf "%P\n"`; do OUTDIR=/home/mnadvornik/NDAT/ReactSL/`dirname $ITEM | cut -d \/ -f 1,2`; if [ ! -d $OUTDIR ]; then mkdir -vp $OUTDIR; fi; mv -v ./$ITEM $OUTDIR/$(basename $ITEM) done
for ITEM in `find ./ -type f -regex '.*/.*convert.cgns' -printf "%P\n"`; do OUTDIR=/home/mnadvornik/NDAT/ReactSL/ReacSL1_forCFD/`dirname $ITEM | cut -d \/ -f 1,2`; if [ ! -d $OUTDIR ]; then mkdir -pv $OUTDIR; fi; mv -v ./$ITEM $OUTDIR/$(basename $ITEM); done

for ITEM in `find ./ -type f -regex '.*/.*convert.cgns' -printf "%P\n"`; do OUTDIR=/home/mnadvornik/NDAT/ReactSL/`dirname $ITEM | cut -d \/ -f 1,2`; if [ ! -d $OUTDIR ]; then echo $OUTDIR; fi; echo ./$ITEM $OUTDIR/$(basename $ITEM) done


 for item in `find ./ -type f -regex '.*.quality.eport'`; do echo $item; grep -n 'Minimal Skewness  Angle:.*' $item; done

for ITEM in `find ./ -type d -name 'data_results'`; do FILESCNT=`ls -1 $ITEM | wc -l`; ALLCNT=$[$ALLCNT+$FILESCNT]; done; echo $ALLCNT

find ./ -type f -regex '.*~[0-9]~'

RESDIR=/home/mnadvornik/CALCUL/2011_Automat2D_NumSolver_latest/settings/
for item in ${BASEDIR[*]}; do cp -v `find $item -type f -regex '.*cfg'` $RESDIR; done

for ITEM in `find ./ -type f -regex '.*/Inputs/.*run'`; do WRDIR=$(dirname $ITEM); grep -rl 'GRID.FILE.*026.*' $WRDIR; done

for item in `find ./ -type f -regex '.*RBi.*.cfg'`; do sed "s/\/home\/mnadvornik\/DATA3/\/mnt\/data3\/cfd/" $item > ../$item; echo "ITEM $item DONE"; done

TEMPDIR=/home/mnadvornik/Data/NumCalc/MeshTemplates/temp_LBk_035_1230_075_308_exp_Re250e3/Re250000
for ITEM in `find ./ -type d -empty -name 'CasePrepare'`; do cp -vr $TEMPDIR $ITEM; done


find ./ -type f -regex '.*/Inputs/.*.run' | grep 'GRID_FILE.*'

for item in `find ./ -type f -regex '.*.quality.eport'`; do echo $item; grep -n 'Minimal Skewness  Angle:.*' $item; done

for ITEM in `find ./ -type f -regex '.*SST.*.res'`; do cfd145post -batch /windows/D/Codes/Ansys_templ/CFDPostcse/2DProfile_results_exports_SST.cse $ITEM; done

expr $test : '.*\(VS33...[0-9].[0-9]\{2\}\)'

rsync -vhr --progress /mnt/data3/Solution-Obnova/cx500/data2/cfd/WORK/2012/2012_084_Secondary_losses_Reac_SL1_Numeca/SOLUTION/ mnt/data2/cfd/WORK/2012/2012_084_Secondary_losses_Reac_SL1_Numeca/SOLUTION/

head -n 102 /mnt/data4/cfd/WORK/2014/2014_019_LBk_035_0680_035_254_exp_CFX/SOLUTION/Calculation/Ma04/data_results_SST_v2/LBk_035_0680_035_254_exp_Re250000_Ma040_SST_001_averes.dat | tail -n 1 >> $RESDIR/LBk_035_0680_035_254_CFXaveres.dat

licence | grep -E 'Users of acfd:.*|acfd_solver.*|anshpc_.*'



 watch "qstat -F lic_cfx_solver,lic_anshpc_pack,counter_cfx_solver,counter_anshpc_pack | grep -m 4 -E 'gc:.*.cfx_solver|gc:.*.anshpc.*'"

qalter -w v 

for item in `find -type f -regex '.*data_results_SA/*.*averes.dat' -printf "%p\n" | sort `; do tail -n 1 $item >> /home/mnadvornik/DATA4/WORK/2014/2014_024_2DProfiles_CFXvsNumeca/SOLUTION/018_LBk_035_0680_035_194_exp_CFX_hub/RESULTS/LBk_035_0680_035_194_CFXaveres_SA.dat ; done


for item in `find -type f -regex '.*data_results_SST/*.*averes.dat' -printf "%p\n" | sort `; do tail -n 1 $item >> ../RESULTS/CFX_outlet_SST.dat; done



cfx2sge_ip 10.29.90.95:0 14.5 4 "/mnt/data4/cfd/WORK/2014/2014_024_2DProfiles_CFXvsNumeca/SOLUTION/LBk_035_0780_075_171_exp_mid/SOLUTION/Ma04/CFX/LBk_035_0780_075_171_exp_Ma04_Re250e3.def" hpc04.q &

for ITEM in `find ./ -type f -regex '.*Frek4.*' -printf "%p\n"`; do if [ ! -d "$(dirname $ITEM)/Freq4" ]; then mkdir -v $(dirname $ITEM)/Freq4; fi; mv -v $ITEM $(dirname $ITEM)/Freq4/$(basename $ITEM); done

for file in `find ./ -type f -name '*.node'`; do NAME=$(echo `basename $file`|cut -d '.' -f 1); awk -F "," '{print $4+1968,"\t",$3,"\t",$2,"\t",$5,"\t",$6,"\t",$7,"\t",$8,"\t",$9,"\t",$10,"\t",$11}' $file > $NAME.dat; done

for file in `find ./ -type f -name '*.node'`; do NAME=$(echo `basename $file`|cut -d '.' -f 1); awk -F "," '{print $4+1174.88,"\t",$3,"\t",$2,"\t",$5,"\t",$6,"\t",$7,"\t",$8,"\t",$9,"\t",$10,"\t",$11}' $file > $NAME.dat; done



FREQ=Freq3;for ITEM in `find ./ -type f -regex '.*Frek3.*' -printf "%p\n"`; do if [ ! -d "$(dirname $ITEM)/$FREQ" ]; then mkdir -v $(dirname $ITEM)/$FREQ; fi; mv -v $ITEM $(dirname $ITEM)/$FREQ/$(basename $ITEM); done

find ./ -type f -regex '.*_HI0_Frek1.*.out' -exec head -n 4 {} \;

for ITEM in `find ./ -type f -regex '.*Frek[1-2].out'`; do OUTDIR=$(dirname $ITEM); FILENAME=$(basename $ITEM | cut -d '.' -f 1); DATA=$(find ./ -type f -name "$FILENAME.dat"); if [ -n "$DATA" ]; then echo "EXECUTE $FILENAME"; head -n 4 $ITEM >> $OUTDIR/$FILENAME.freq; less $DATA >> $OUTDIR/$FILENAME.freq; fi; done


find ./ -type f -regex '.*/2014_03[0-5]_.*/Inputs/.*.cfg' -exec cp '{}' /home/mnadvornik/CALCUL/2011_Automat2D_NumSolver_latest/settings \;


find ./ -type f -regex '.*Frequency[1-4].*' -exec mv -v '{}' ./ \;


tar -cvzf M7_L-1Frequency4.tar.gz *.out

FREQ=Freq4;for ITEM in `find ./ -type f -regex '.*Frek4.*' -printf "%p\n"`; do if [ ! -d "$(dirname $ITEM)/$FREQ" ]; then mkdir -v $(dirname $ITEM)/$FREQ; fi; mv -v $ITEM $(dirname $ITEM)/$FREQ/$(basename $ITEM); done

 find ./ -type d -regex '.*2013.*.Amager.*/Results' -printf "$(pwd)/%P\n" -exec /windows/D/Codes/noneswtools/Bash/trunk/solve_resulting_onedir.sh '{}' \;

find ./ -type d -regex '.*005_PNk.*/Results' -exec /windows/D/Codes/noneswtools/Bash/trunk/Graph2DAllPropertyOfRun_inc_Incidence.sh '{}' \;

find ./ -type d -regex '.*PNk.*/Results' -exec /windows/D/Codes/noneswtools/Bash/trunk/Graph2DAllPropertyOfRun.sh '{}' \;

grep 'Coordinates (cartesian).*' ./hub_shroud_vertex.dat | cut -d \(  -f 3 > ./M7_merid_vertex.dat 

grep -E '.*vertex|edge.*' ./hub_dataexport_from_gambit_stage_without_tip_leakage.dat | awk '$0 ~ /[0-9]*/ {print $4, $3, $2}' > ./hub_dataexport_from_gambit_stage_without_tip_leakage_filtered.dat

 cat $SOURCEFILE | grep 'section.[0-9]\?' | cut -d ' ' -f 3 | sort -nu | tail -n -1
tac ./bucket_pressure_side.dat > ./bucket_pressure_side.dat
 awk '/PRESSURE/, G  {print $0}' $SOURCEFILE | awk '$0 ~ /[0-9]/ {print $0}'
awk '/SUCTION/,/PRESSURE/  {print $0}' $SOURCEFILE | awk '$0 ~ /[0-9]/ {print $0}' > ./bucket_suction_side.dat
 awk '/PRESSURE/, G  {print $0}' $SOURCEFILE | awk '$0 ~ /[0-9]/ {print $0}' | tac > ./nozzle_pressure_side.dat

for item in `find ./ -type f -name '*.out'`; do NAME=`basename $item | cut -d \. -f 1`".dat"; echo $NAME; done

for file in `find ./ -type f -name '*.node'`; do NAME=$(echo `basename $file`|cut -d '.' -f 1); awk -F "," '{print $4+1968,"\t",$3,"\t",$2,"\t",$5,"\t",$6,"\t",$7,"\t",$8,"\t",$9,"\t",$10,"\t",$11}' $file > $NAME.dat; done


 awk '$1 ~ /[[:digit:]]/ && $2 ~ /[[:digit:]]/ && $3 ~ /[[:digit:]]/ && $1 !~ /[+2]/ { print $0 }'




Process for transform node and out file to freq:

0)
FREQ=Freq2;for ITEM in `find ./ -type f -regex '.*Frek2.*' -printf "%p\n"`; do if [ ! -d "$(dirname $ITEM)/$FREQ" ]; then mkdir -v $(dirname $ITEM)/$FREQ; fi; mv -v $ITEM $(dirname $ITEM)/$FREQ/$(basename $ITEM); done

1) 
for file in `find ./ -type f -name '*.node'`; do NAME=$(echo `basename $file`|cut -d '.' -f 1); awk -F "," '{print $4+1174.88,"\t",$3,"\t",$2,"\t",$7,"\t",$6,"\t",$5,"\t",$10,"\t",$9,"\t",$8}' $file > $NAME.dat; done

2)
for item in `find ./ -type f -name '*.out'`; do DATAFILE="./"`basename $item | cut -d \. -f 1`".dat"; OUTFILE=`basename $item | cut -d \. -f 1`".freq"; awk '$0 ~ /ShapeNo/ {print $0}' $item > $OUTFILE; printf "\t# Data X,Y,Z,UX,UY,UZ, i*UX, i*UY, i*UZ\n" >> $OUTFILE; awk '$0 ~ /Kinetic energy/ {print $0}' $item >> $OUTFILE; cat $DATAFILE >> $OUTFILE; echo "File $OUTFILE done."; done

3) 
tar -cvzf M7_L-1FamilyMode2.tar.gz *.freq


awk '$0 ~ /[[:digit:]]/ && $0 !~ /[[:alpha:]]/  {print $3," ",$2," ",$1}; $0 ~ /[[:alpha:]]/ {print "\n"$0}' ./blade_M5L-0_RL.curve > blade_M5L-0_RLv2.curve

for item in `find ./ -type f -name '*.out'`; do DATAFILE="./"`basename $item | cut -d \. -f 1`".dat"; OUTFILE=`basename $item | cut -d \. -f 1`".freq"; awk '$0 ~ /ShapeNo/ {print $0}' $item > $OUTFILE; awk '$0 ~ /Data/ {print $0}' $item >> $OUTFILE; awk '$0 ~ /Kinetic energy/ {print $0}' $item >> $OUTFILE; cat $DATAFILE >> $OUTFILE; echo "File $OUTFILE done."; done



for file in `find ./ -type f -name '*.out'`; do NAME=$(echo `basename $file`|cut -d '.' -f 1); awk -F "," 'NR >= 5 {print $1*(-1)+1174.88,"\t",$2*-1,"\t",$3,"\t",$4*-1,"\t",$5*-1,"\t",$6,"\t",$7*-1,"\t",$8*-1,"\t",$9}' $file > $NAME.dat; done





for file in `find ./ -type f -name '*.out'`; do NAME=$(echo `basename $file`|cut -d '.' -f 1); awk -F "," 'NR >= 5 {print "\t",210.4+$1*-1,"\t",$2*-1,"\t",$3,"\t",$4*-1,"\t",$5*-1,"\t",$6,"\t",$7*-1,"\t",$8*-1,"\t",$9}' $file > $NAME.dat; done



find ./ -type f -regex '.*_090_.*.\(geom.urbo\|bc\)' -exec mv -v '{}' /home/mnadvornik/Data/Profile_files \;


datfile = importdata('./M7L0ListRotace_HI0_Frek1.dat');
outdata = importdata('./M7L0ListRotace_HI0_Frek1_test.out');
plot3(outdata(:,3),outdata(:,2),outdata(:,1), '.r')
plot3(datfile(:,1),datfile(:,2),datfile(:,3), '.b')
plot3(outdata(:,3)+outdata(:,6),outdata(:,2)+outdata(:,5),outdata(:,1)+outdata(:,4), '.c')
plot3(datfile(:,1)+datfile(:,4),datfile(:,2)+datfile(:,5),datfile(:,3)+datfile(:,6), '.c')


awk '$0 ~ /[[:digit:]]/ && $0 !~ /[[:alpha:]]/ {print $0}' ./M7L1_HI0_Frek1.out 

awk 'NR >= 5 {print $0}' M7L1_HI0_Frek1.out

awk '$0 ~ /[[:digit:]],/ && $0 !~ /[[:alpha:]]/ {print 210.4+$1*-1,"\t",$2*-1,"\t",$3,"\t",$4*-1,"\t",$5*-1,"\t",$6,"\t",$7*-1,"\t",$8*-1,"\t",$9}'

awk '{ if ($0 ~ /Frequency/) print $1,$2,90.2,$4; else if ($0 ~ /Maximum.*/) print $1,$2,$3,14.5,$5,$6;}' ./M5_mode1_1p_templ.csv | head -n 



"/opt/sw/MATLAB/R2011a/bin/matlab -nosplash -nodesktop -r \"cd('/windows/D/Codes/doosanskodapower/MSteamDlg/trunk/third_parties/'),get_refValue('{0}', '{1}', {2:6.8f}),exit\""

$SOURCEFILE=/mnt/data3/cfd/WORK/2014/2014_029_SPWR_Modul5_L-0_flutter/SETTINGS/Node/Freq1/M5L0_HI1_Frek1.freq;/opt/sw/MATLAB/R2011a/bin/matlab -nosplash -nodesktop -r "addpath('/windows/D/Codes/noneswtools/MFiles/trunk'),get_maxdisplacement_fromFile('$SOURCEFILE')"

 awk 'NR >= 4 { gsub(/\t/,",",$0); gsub(/\s/,"",$0); print }' 


TEMPL=''

for item in `find ./ -type f -regex '.*RBi.*_140_.*cfg'`; do sed "s/\/home\/mnadvornik\/DATA3/\/mnt\/data3\/cfd/" $item > ../$item; echo "ITEM $item DONE"; done


/opt/sw/MATLAB/R2011a/bin/matlab -nosplash -nodesktop -nodisplay -r "addpath('/windows/D/Codes/noneswtools/MFiles/trunk'),sprintf('Maximum Displacement = %.5f',get_maxdisplacement_fromFile('$SOURCEFILE')),exit" | grep 'Maxim.*Displa.*'



/opt/sw/MATLAB/R2011a/bin/matlab -nosplash -nodesktop -r "addpath('/windows/D/Codes/noneswtools/MFiles/trunk'),get_maxdisplacement_fromFile('$SOURCEFILE'),exit"


TEMPL="/mnt/data3/cfd/WORK/2014/2014_029_SPWR_Modul5_L-0_flutter/SETTINGS/M5_mode1_1p_templ.csv"
HEAD="[Name],,,,,,,,\nmode1,,,,,,,,\n,,,,,,,,\n[Parameters],,,,,,,,\n"
TAIL=",,,,,,,,\n[Spatial Fields],,,,,,,,\nInitial X, Initial Y, Initial Z,,,,,,\n,,,,,,,,\n[Data],,,,,,,,\nInitial X [ mm ], Initial Y [ mm ], Initial Z [ mm ], meshdisptot x [ mm ], meshdisptot y [ mm ], meshdisptot z [ mm ],Imaginary meshdisptot x [ mm ],Imaginary meshdisptot y [ mm ],Imaginary meshdisptot z [ mm ]\n"

OUTNAME="M5_mode1_ND"

for ITEM in `find ./ -type f -name '*.freq' | sort`
do 
	  MAXDISPL=`/opt/sw/MATLAB/R2011a/bin/matlab -nosplash -nodesktop -nodisplay -r "addpath('/windows/D/Codes/noneswtools/MFiles/trunk'),sprintf('Maximum Displacement = %.5f [mm],,,,,,,,',get_maxdisplacement_fromFile('$ITEM')),exit" | grep 'Maxim.*Displa.*'`
	  NAME=`basename $ITEM | cut -d \. -f 1`
	  DIR=`dirname $ITEM`
	  NODALDIAMETER=`awk '$0 ~ /HI/ {print $5)' $ITEM`
	  FREQUENCY=`awk '$0 ~ /Frequency/ {print $5)' $ITEM`
	  KINENERGY=`awk '$0 ~ /Kinetic.energy/ {print sqrt($5**2+$8**2)}' $ITEM`

	  OUTNAME=$OUTNAME$NODALDIAMETER".csv"

	  #insert head	  
	  printf "%s" "$HEAD" > $OUTNAME

	  #insert parameters  
	  printf "Frequency = %s [Hz],,,,,,,,\n" "$FREQUENCY" >> $OUTNAME
	  printf "%s\n" "$FREQUENCY" >> $OUTNAME

	  #insert tail
	  printf "%s" "$TAIL" >> $OUTNAME

	  awk 'NR >= 4 { print $3,",",$2,",",$1,",",$6,",",$5,",",$4,",",$9,",",$8,",",$7 }' $ITEM >> $OUTNAME

	  echo "FILE WITH NAME $OUTNAME WAS CREATED."

done


awk 'BEGIN {FS=","}; NR >= 4 { gsub(/\t/,",",$0); gsub(/\s/,"",$0); print }'
awk 'NR >= 4 { print $3,",",$2,",",$1,",",$6,",",$5,",",$4,",",$9,",",$8,",",$7 }'

awk ' $0 ~ /[[:digit:]]/ && $0 !~ /[[:alpha:]]/ && $1 !~ /2.0/ { print $0 }' ./RBi_070_0700_040_138_exp_te4.geomTurbo

## 2D profily - fronta prikazu

# zkopirovat zadani pro inicializaci projektu
find ./ -type f -regex '.*_140_.*.\(geom.urbo\|bc\)' -exec mv -v '{}' /home/mnadvornik/Data/Profile_files \;

# nastavit sablonu pro vypocet do adresare ../Data/CalcsTempl, popr. vygenerovat sit rucne pro jeden vypocet a nasledne pouzit sablonu

# upravit konfiguracni soubor
react_blade2D_projectprepare.cfg

# spustit skript pro vytvoreni projektu
react_blade2D_projectprepare.sh    							# pokud zadani okrajovych podminek ma shodne jmeno jako jmeno souboru se siti
react_blade2D_projectprepare_bcForAll_oneReyno.sh 		# pokud zadani okrajovych podminek je jedno pro vsechny geometrie

find ./ -type d -regex '.*/.*04[2-7].RB.*/Inputs/Case.*/ReForAll.*/Re.*' -exec cp -v /home/mnadvornik/Data/NumCalc/MeshTemplates/ReForAll/RBi_035_0700_090_106_exp_c030/ReForAllSST/ReForAll_ReForAll_Ma0x/* '{}' \;

find ./ -type f -regex '.*043.RB.*/Inputs/.*.cfg' -exec cp -v '{}' /home/mnadvornik/CALCUL/2011_Automat2D_NumSolver_latest/settings \;


find /home/mnadvornik/DATA3/WORK/2014/2014_055 -maxdepth 2 -type d -regex '.*/Results' -exec ./results_export.sh '{}' \;

find /home/mnadvornik/DATA3/WORK/2014/2014_055 -name '*.zip' -exec mv -v '{}' /home/mnadvornik/DATA3/WORK/2014/2014_055 \;


find ./ -regex '.*mode1.*ND[0-9]+.csv' -exec awk -v namefile='{}' '$0 ~ /Maximum.*Displa/ { print namefile,"\t",$4,"\t",4/$4,"\t",(4/$4)**2;}' '{}' >> Mode1_maxDisplacement.dat \;


awk 'BEGIN{ print "Name\tMax.Displacement[mm]\tScaleFactor[-]\tPowerSF[-]";}' > Mode1_maxDisplacement.dat

find ./ -regex '.*mode1.*ND[0-9]+.csv' -exec awk -v namefile='{}' '{ if($0 ~ /Maximum.*Displa/){ print namefile,"\t",$4,"\t",4/$4,"\t",(4/$4)**2;}else if($0 ~ /Frequency/){frequency=$3}}' '{}' >> Mode1_maxDisplacement.dat \;

find ./ -regex '.*mode1.*ND[0-9]+.csv' -exec awk -v namefile='{}' '{ if($0 ~ /Maximum.*Displa/){ print namefile,"\t",frequency,"\t",$4,"\t",4/$4,"\t",(4/$4)**2;}else if($0 ~ /Frequency/){frequency=$3}}' '{}' >> Mode1_maxDisplacement.dat \;
awk 'BEGIN{ print "Name\tFrequency[Hz]\tMax.Displacement[mm]\tScaleFactor[-]\tPowerSF[-]";}' > Mode1_maxDisplacement.dat

find ./ -maxdepth 1 -type f -regex '.*M5_mode2.*ND\(10\|15\|20\)+.def' -exec cfx2sge_bp 15.0 128 "'{}'" hpc03.q \;

find ./ -maxdepth 1 -type f -regex '.*M5_mode1.*[0-9]+.def'-exec cfx2sge_bp 15.0 128 "'{}'" hpc03.q \;
























