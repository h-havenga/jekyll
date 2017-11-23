#!/bin/bash

# MAKE A MAP!
# Define the names of the input, output and coordinates details: 
out=south_africa.ps           # This will be the name of the map

# Lets do the boundaries
north=-22
south=-35
east=34
west=15

# Color intensities (RGB) g for ground and s for sea
g_red=100
g_green=200
g_blue=100

s_red=0
s_green=50
s_blue=250

# Define the border ticks and projection (mercator)
tick='-B2.5/2.5WSen'
proj='-JM20'

# Lets make a base map by calling GMT and open it so you can see the
# development interactively 
gmt psbasemap -R$west/$east/$south/$north $proj $tick -X5 -K > $out

# Lets start drawing some boundaries
# N = National Borders (Na = National Borders All)
gmt pscoast -R -J -O -K -W0.25 -Df -B+t"South Africa" -Na -W0.05 -G$g_red/$g_green/$g_blue -S$s_red/$s_green/$s_blue >> $out
