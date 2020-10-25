#!/bin/bash
#
#   Shell upravi vstupni soubor obsahujici souradnice profilu
#   a pomoci Gambitu vygeneruje urceny pocet bodu po profilu.
#   Vznikly soubor nasledne upravi tak, aby bylo mozne nacist do GridPra.
#
#Program se spousti:
#  ./GridPro-sit01 vst_soub_sig
#
#   vst_soub_sig jmeno souboru obsahujici definovane body profilu bez pripony
#
#
VSTSOUBSIG=$1
VSTSOUB=`echo $VSTSOUBSIG".d"`
OUTPUTFILE=`echo $VSTSOUBSIG".dat"`
# zanechaji se pouze radky, ktere maji dve pole, tj. souradnice x a y
awk '{if (NF == 2) {print $0} else {}}' $VSTSOUB > smazat01.tmp
# prida se treti sloupec reprezentujici souradnici z (z=0)
awk 'C="0.0" {printf("%10s\n %10s %10s\n",$1,$2,C)}' smazat01.tmp > $OUTPUTFILE
rm smazat01.tmp
#
#
#
#   V souboru TGambit_priprava01.jou nahradime nazev nacteneho souboru pozadovanym nazvem
awk '{if ($1 == "$fnamesig") {print "$fnamesig = \""FNAMESIG"\""} else {print $0}}' FNAMESIG=$1 TGambit_priprava01.jou > TGambit_priprava02.jou
awk '{print $0}' TGambit_priprava02.jou > TGambit_priprava01.jou
rm TGambit_priprava02.jou
# Spousteni Gambitu na pozadi bez grafickeho modu
gambit -inp TGambit_priprava01.jou
# Spousteni Gambitu na pozadi v grafickem modu
#gambit -init TGambit_priprava01.jou
#
#
#
VSTSOUB=`echo $VSTSOUBSIG".trn"`
#   Zanechaji se pouze radky ktere maji v prvnim sloupci pomlcky nebo cisla
awk '($1 ~ /^-------/) || ($1 ~ /^[1-9]/) {print $0}' $VSTSOUB > smazat01.tmp
#   Zapise se hlavicka obsahujici pocet bodu a cislo 1
awk '{p[NR]=$1}
      END {nrad=NR-11
           printf("%10d %2s\n",nrad," 1")
          }
     ' smazat01.tmp > $OUTPUTFILE
#   Ze souboru se vyradi radky s pomlckama a druhy radek nasledujici za pomlckama
awk '{nrdel=0
       xsour[NR]=$2
       ysour[NR]=$3
       zsour[NR]=$4}
      END {{for(i=1;i<NR+1;i++)
            {if (xsour[i] ~ /-------/) {nrdel = i+2} else {if (i == nrdel) {} else {printf("%10s %10s %10s\n", xsour[i], ysour[i], zsour[i])}}}
          }
          {printf("%10s %10s %10s\n", xsour[2], ysour[2], zsour[2])}}
     ' smazat01.tmp >> $OUTPUTFILE
rm smazat01.tmp
 
