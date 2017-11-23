#!/bin/bash

# MAKE A MAP!
# Define the names of the input and output files
out=southafrica_topo.ps                           # This will be the name of
topo=./ETOPO1_Bed_g_gmt4.grd                   # ETOPO1 topography grid
admin=ZAF_adm1.gmt			       # Provincial boundaries

# Define map characteristics
# Define your area 15/33.5/-35/-22 
north=-22
south=-35
east=34
west=15

tick='-B2.5/2.5WSen'
proj='-JM20'

gmt psbasemap -R$west/$east/$south/$north $proj $tick -X6 -K > $out
gmt makecpt -Crelief -T-7500/7500/200 -Z > topo.cpt
gmt grdimage $topo -R -J -O -K -Ctopo.cpt >> $out
gmt pscoast -R -J -O -K -W0.25 -Df -B+t"South Africa" -Na0.05 -I1/0.25p,skyblue3 -I2/0.25p,skyblue3 >> $out
gmt psxy $admin -R -J -K -O -W0.05 -V >> $out
open $out
