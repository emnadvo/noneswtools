# template file for plot style for gnuplot
# created 07/10/2013
# version 1.0.5
# created by mnadvornik

reset

# odstrani okraj grafu
unset border
# border 15 = 7 + 8 it is integer value code for border lines
set border 15 lw 1.5
#set border 4095 lw 5

#nastavi style pouzity pro vykresleni dat napr. ze souboru - body spojene primkou, bez vyhlazeni
#set style data linespoints
#set autoscale xfix

#nastavi velikost znacek
set tics scale 1.0, 0.8

# nastaveni zobrazeni vedlejsich znacek
#set mxtics 5; set mytics 5

# nastaveni zobrazeni site vedlejsich a hlavnich znacek a stylu mrizky
#set grid xtics ytics mxtics mytics lt 1 lc rgb "dark-green" lw 0.7, lt 0.5 lc rgb "dark-green" lw 0.5
set grid xtics ytics lt 1 lc rgb "dark-green" lw 0.7
# zmeni format hodnot na ose x   light-blue
#set format x "%2.1f"
# zmeni format hodnot na ose y
#set format y "%1.6f"

#set xtics xmin,deltaX,xmax #nastavi pocet hlavnich dilku dle deltax do xmax z xmin
#set ytics ymin,deltaY,ymax  #nastavi pocet hlavnich dilku dle deltay do ymax z ymin

# nastaveni jmena osy x
#set xlabel "Jmeno"
# nastaveni jmena osy y
#set ylabel "jmeno"
# nastaveni jmena grafu
#set title "Jmeno grafu"

#nastaveni vystupu do obrazku jpeg
#set terminal jpeg large font arial size 1280,1024
#set output "jmeno_grafu.jpeg"

set encoding utf8

#nastaveni legendy stred
#set key bottom
#set term png enhanced font VeraSe 20 size 1600, 1010
set xtics  nomirror
set ytics  nomirror

#set datafile fortran
set datafile commentschars "#*"
#set datafile separator "\t"
# nastaveni pro aktivaci nahrazovaciho retezce
set macros


#A4 in px size 3507, 2480
set terminal png font "arial" 20 size 3487, 2460
#set terminal postscript enhanced font "Helvetica" 12

# vyrez z vysledku pro site
# every_hexatetra_mesh="every 1:1:0:0:3:0"
# every_tetra_mesh="every 1:1:4:0:15:0"

# styly bodu a linek
style_circle_pnt="with points pt 6 ps 1.5"
style_fullcircle_pnt="with points pt 7 ps 1.5"
style_triangleup_pnt="with points pt 8 ps 1.5"
style_fulltriangleup_pnt="with points pt 9 ps 1.5"
style_cross_pnt="with points pt 2 ps 1.5"
style_square_pnt="with points pt 4 ps 1.5"
style_fullsquare_pnt="with points pt 5 ps 1.5"
style_fulltriangldown_pnt="with points pt 11 ps 1.5"
style_diamond_pnt="with points pt 12 ps 1.5"
style_fulldiamond_pnt="with points pt 13 ps 1.5"

style_tetrahex_ln="with lines lt 3 lw 2.0"
style_tetra_pnt="with points pt 5 ps 1.5"
style_tetra_ln="with lines lt 3 lw 2.0"

style_test_pnt="with points pt 19 ps 1.3"
style_fulline_ln="with lines lt 1 lw 1.1"
style_fulline_bld_ln="with lines lt 1 lw 2.2"

# barvy car
color_red="lc rgb \"red\""
color_blue="lc rgb \"blue\""
color_dgreen="lc rgb \"dark-green\""
color_green="lc rgb \"green\""
color_brown="lc rgb \"brown\""
color_magenta="lc rgb \"magenta\""
color_dyellow="lc rgb \"dark-yellow\""
color_yellow="lc rgb \"yellow\""
color_orange="lc rgb \"orange\""
color_pink="lc rgb \"pink\""
color_black="lc rgb \"black\""

# fonty 
xy_font = '"Helvetica,12"'
title_font = '"Helvetica,14"'
graph_font = '"Helvetica,14"'
label_offset = 'offset 1.0,-0.15'
title_offset = 'offset 0.0,0.25'
smooth_line="smooth bezier"

#########################################################################################
## MAIN PART WITH SETTINGS WITH ACTUAL CASE
#########################################################################################
#Datafile

#Final directory with graphs picture
output_dir='"TURBODIRNAME'
data_file="'FILENAME'"

#set yrange [0:1]
#set xrange [0:0.6]
#square graph
set size square

#Final picture save to directory
#set output @output_dir/Inlet_Alfa2_VtVm.ps"

# nastaveni osy X
#set xlabel "{/Symbol a} [rad]" @label_offset font @xy_font

# nastaveni osy Y
#set ylabel "{/Symbol z}_c [-]" @label_offset font @xy_font
#set ylabel "|R| [-]" @label_offset font @xy_font

#range_1="using ($3*000):2"
range_plane1="using 3:2"

# nastaveni nazvu v grafu
tit_plane1 = "title 'alfa by TSE'"


########################################## MAIN PLOT CMD ##########################################

set title "2D profile PROFILE" font "DejaVuSans-Oblique,18"

set output @output_dir/PROFILE.png"

plot @data_file @range_plane1 @style_fulline_bld_ln @color_blue notitle

exit
