---
layout: post
title:  "GMT Part 3: Working with netCDF data by creating a synoptic weather map"
date:   2017-11-30 10:00:29 +0200
categories: maps data
---

For my thesis I had to examine synoptic scale circulation over
South-Africa, I wanted to recreate a *classic* synoptic map that
represented mean sea level pressure and also geopotentail at 500hPa.
I knew the [South-African Weather Service
(SAWS)](http://www.weathersa.co.za/) has [daily
maps](http://www.weathersa.co.za/observations/synoptic-charts) they
make publicly available, but the maps are not always the highest
quality as they are hand drawn and I am not the biggest fan of the
SAWS policies. 

![sawsmap]({{ "/assets/images/maps/synoptic_20121109.png" | absolute_url }})
<sub>A SAWS synoptic map. </sub>

In addition to this I was also attempting to better understand GMT's
handling of NetCDF files. I used ERA-Interim data in my thesis for WRF
and also some objective clustering, the ERA dataset was thus the
obvious choice. Using GMT to recreate these synoptic maps took me a
couple of days, mostly the time consumption was related to handling
the netCDF data.  GMT uses Reverse Polish Notation (RPN) for math
functions which I needed to figure out as you'll see. It is also
useful to have CDO, ncview and ncdump installed for data inspection
and manipulating. A last point is that I compiled it all in a bash
script, this is useful for various reasons, so just learn to do it.

{% highlight bash %}
#!/bin/bash
#
#####################################################
# This script is used to make a synoptic map        #
# http://gmt.soest.hawaii.edu/boards/1/topics/5997  #
#####################################################
#####################################################
# Step 1: Download the ERA-DATA                     #
#####################################################

python << EOF
from ecmwfapi import ECMWFDataServer
server = ECMWFDataServer()
server.retrieve({
    "class": "ei",
    "dataset": "interim",
    "date": "2012-11-09/to/2012-11-09",
    "expver": "1",
    "grid": "0.75/0.75",
    "levtype": "sfc",
    "param": "151.128",
    "step": "0",
    "stream": "oper",
    "time": "12:00:00",
    "type": "an",
    "format":"netcdf",
    "target": "msl.nc",
})

server.retrieve({
    "class": "ei",
    "dataset": "interim",
    "date": "2012-11-09/to/2012-11-09",
    "expver": "1",
    "grid": "0.75/0.75",
    "levelist": "500",
    "levtype": "pl",
    "param": "129.128",
    "step": "0",
    "stream": "oper",
    "time": "12:00:00",
    "type": "an",
    "format":"netcdf",
    "target": "zg500.nc",
})
EOF

read -p "ERA-Data downloaded. Press enter to continue and convert data for use in GMT "

#############################################################################
#  The file is not compatible with GMT as is, to get it to work use         #
#  'msl.nc?msl to selects the variable we want and writes it to mslp.nc.    # 
#  The '' is important otherwise bash looks for a wildcard.                 #
#  The units are also scaled and to correct them we need to use gmt grdmath #
#############################################################################

gmt grdconvert 'msl.nc?msl' -Gmslp_org.nc
gmt grdedit mslp_org.nc -R-180/180/-90/90 -S
gmt grdmath mslp_org.nc 100 DIV = mslp_nrm.nc

gmt grdconvert 'zg500.nc?z' -Gzg500_org.nc
gmt grdedit zg500_org.nc -R-180/180/-90/90 -S
gmt grdmath zg500_org.nc 10 DIV = zg500_nrm.nc

read -p "Lets inspect the data with ncdump. Press enter to continue "
ncdump -h mslp_nrm.nc
ncdump -h zg500_nrm.nc

read -p "Lets inspect the data with grdinfo. Press enter to continue "
gmt grdinfo mslp_nrm.nc
gmt grdinfo zg500_nrm.nc

read -p "Data successfully converted. Lets create a world map. Press enter to continue "

####################################################
# Here we create a very basic map to view our data #
####################################################

echo 'MSLP map '
gmt grdimage mslp_nrm.nc -JX25/0d -K > mslp.ps
gmt pscoast -Rmslp_nrm.nc -JX -W0.5 -N3 -O -Dc >> mslp.ps

echo 'Geopotential map '
gmt grdimage zg500_nrm.nc -JX25/0d -K > zg500.ps
gmt pscoast -Rzg500_nrm.nc -JX -W0.5 -N3 -O -Dc >> zg500.ps

read -p "World map created. Lets create a map of South-Africa. Press enter to continue "

####################################################################
#Now we need to create a contoured map from the netcdf file for SA #
####################################################################
topo='ETOPO1_Bed_g_gmt4.grd'
out='southafrica_syn_28Nov2013.ps'

#Coordinates (actually lower left and upper right not E S W N) 
east=-20
south=-46
west=60
north=-12r

#Projection (Lambert Azimuthal Equal-Area)
width=25.5

gmt psbasemap  -R$east/$south/$west/$north -JA25/-30/$width -Xc -Yc -B15a0g15 -K > $out
gmt makecpt    -Crelief -T-8500/8500/100 -Z > topo.cpt
gmt grdimage   -R -JA $topo -Ctopo.cpt -O -K >> $out
gmt pscoast    -R -JA -W -Df -N1 -O -K >> $out
gmt grdcontour -R -JA -Wthinnest mslp_nrm.nc -C2 -A2 -O -K >> $out
gmt grdcontour -R -JA -Wthick,red zg500_nrm.nc -C100 -A100+v -P -Gn1 -O -K >> $out
gmt psxy ZAF_adm1.gmt -R -JA -O -Wfaint -V -K >> $out

read -p "Done. Press enter to continue "
{% endhighlight %}

And this gives us a new and improved synoptic map.
![gmtsynopticmap]({{ "/assets/images/maps/synoptic09Nov2012.png" | absolute_url }})
