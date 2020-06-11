---
layout: post
title:  "The worst automated bash-WRF script ever, but it works, most of the time"
date:   2020-06-11 09:40:29 +0200
categories: WRF  
---

Do not attempt this at home, this is a hack job, but it works if you have WRF
compiled and you add to your crontab

{% highlight bash %}
#!/bin/bash

#########################################
#           Get GFS Data                #
#########################################
# Copy the newest gfsdata from the gfsruns under ~/gfsforecast here
echo "
############################
##     Getting GFS data    #
############################"

echo

# Remove any old GFS files
rm GFS/*

# Copy new files 
# Sometimes GFS scripts stops before moving files to the correct path
#cp -v ~/gfs_forecast/gfs.t00z.pgrb2.0p25* GFS/ &
#cp -v ~/gfs_forecast/gfs_archive/gfs_$today/00h/gfs.t00z.pgrb2.0p25* GFS/ &

today=$(date +"%Y%m%d")
gfs=https://ftp.ncep.noaa.gov/data/nccf/com/gfs/prod/gfs
forecast=(00 02 04 06 08 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60 62 64 66 68 70 72 74 76 68 80)
for i in "${forecast[@]}" 
do 
    axel -a $gfs.$today/00/gfs.t00z.pgrb2.0p25.f0$i & 
done

wait

mv gfs.t00z.pgrb2.0p25* GFS/

# Remove all incomplete GFS files
rm GFS/*st

#########################################
#           Edit namelists              #
#########################################
# Edit the WPS file and get the newest dates
today=$(date +"%Y-%m-%d")
tomorrow=$(date --date="2 days" +"%Y-%m-%d")

echo "&share
 wrf_core = 'ARW',
 max_dom = 1,
 start_date = '${today}_12:00:00', 
 end_date   = '${tomorrow}_12:00:00', 
 interval_seconds = 7200,
 io_form_geogrid = 2,
 debug_level = 0,
/

&geogrid
 parent_id         = 1,
 parent_grid_ratio = 1,
 i_parent_start    = 1,
 j_parent_start    = 1,
 e_we          = 100,
 e_sn          = 91,
 geog_data_res = 'default',
 dx = 33000,
 dy = 33000,
 map_proj =  'mercator',
 ref_lat   = -28.344,
 ref_lon   = 25.064,
 truelat1  = -28.344,
 truelat2  = 0,
 stand_lon = 25.064,
 geog_data_path = '../WPS_GEOG'
 ref_x = 50.0,
 ref_y = 45.5,
/

&ungrib
 out_format = 'WPS',
 prefix = 'FILE',
/

&metgrid
 fg_name = 'FILE'
 io_form_metgrid = 2,
/
" > WPS/namelist.wps

# Next change the namelist in WRF
year=$(date   +"%Y")
month=$(date  +"%m")
today=$(date  +"%d")

tyear=$(date  --date="2 days" +"%Y")
tmonth=$(date --date="2 days" +"%m")
tday=$(date   --date="2 days" +"%d")

echo "&time_control
 run_days                            = 0,
 run_hours                           = 48,
 run_minutes                         = 0,
 run_seconds                         = 0,
 start_year                          = $year,
 start_month                         = $month,
 start_day                           = $today,
 start_hour                          = 12,
 start_minute                        = 00,
 start_second                        = 00,
 end_year                            = $tyear,
 end_month                           = $tmonth,
 end_day                             = $tday,
 end_hour                            = 12,
 end_minute                          = 00,
 end_second                          = 00,
 interval_seconds                    = 7200,
 input_from_file                     = .true.,
 history_interval                    = 5,
 frames_per_outfile                  = 1,
 restart                             = .false.,
 restart_interval                    = 120,
 io_form_history                     = 2
 io_form_restart                     = 2
 io_form_input                       = 2
 io_form_boundary                    = 2
 nwp_diagnostics                     = 1
 debug_level                         = 0
/

&domains
 time_step                           = 180,
 time_step_fract_num                 = 0,
 time_step_fract_den                 = 1,
 max_dom                             = 1,
 e_we                                = 100,
 e_sn                                = 91,
 e_vert                              = 36,
 p_top_requested                     = 5000,
 num_metgrid_levels                  = 34,
 num_metgrid_soil_levels             = 4,
 dx                                  = 33000,
 dy                                  = 33000,
 grid_id                             = 1,
 parent_id                           = 0,
 i_parent_start                      = 1,
 j_parent_start                      = 1,
 parent_grid_ratio                   = 1,
 parent_time_step_ratio              = 1,
 feedback                            = 1,
 smooth_option                       = 0
/

&physics
 mp_physics                          = 6,    -1,    -1,
 cu_physics                          = 1,    -1,     0,
 ra_lw_physics                       = 3,    -1,    -1,
 ra_sw_physics                       = 3,    -1,    -1,
 bl_pbl_physics                      = 1,    -1,    -1,
 sf_sfclay_physics                   = 1,    -1,    -1,
 sf_surface_physics                  = 2,    -1,    -1,
 radt                                = 30,    30,    30,
 bldt                                = 0,     0,     0,
 cudt                                = 5,     5,     5,
 icloud                              = 1,
 num_land_cat                        = 21,
 sf_urban_physics                    = 0,     0,     0,
 do_radar_ref                        = 1,

/

&fdda
/

&afwa
 afwa_diag_opt			 = 1,
 afwa_ptype_opt  		 = 1,
 afwa_severe_opt    	   	 = 1,
 afwa_vil_opt       	   	 = 1,
 afwa_radar_opt     	   	 = 1,
 afwa_icing_opt     	   	 = 1,
 afwa_vis_opt       	   	 = 1,
 afwa_cloud_opt     	   	 = 1,
 afwa_therm_opt     	   	 = 1,
 afwa_turb_opt      	   	 = 1,
 afwa_buoy_opt      	   	 = 1,
 afwa_ptype_ccn_tmp 		 = 268.15,
 afwa_ptype_tot_melt         = 25,
/

&dynamics
 hybrid_opt                  = 2,
 w_damping                   = 1,
 diff_opt                    = 12      1,      1,
 km_opt                      = 4,      4,      4,
 diff_6th_opt                = 0,      0,      0,
 diff_6th_factor             = 0.12,   0.12,   0.12,
 base_temp                   = 290.
 damp_opt                    = 3,
 zdamp                       = 5000.,  5000.,  5000.,
 dampcoef                    = 0.2,    0.2,    0.2
 khdif                       = 0,      0,      0,
 kvdif                       = 0,      0,      0,
 non_hydrostatic             = .true., .true., .true.,
 moist_adv_opt               = 1,      1,      1,
 scalar_adv_opt              = 1,      1,      1,
 gwd_opt                     = 1,
/

&bdy_control
 spec_bdy_width              = 5,
 specified                   = .true.
/

 &grib2
/

&namelist_quilt
 nio_tasks_per_group = 0,
 nio_groups = 1,
/
" > WRF/run/namelist.input

###################################################
# Now run WPS first
echo "
###########################
#	Running WPS       #
###########################"

echo

# Go to the WPS directory
cd WPS

# Remove old files
rm FILE:* met_em* geo_em* 

# Link to the GFS archive where the GFS data lies
# And explicitly say which data we use (Vtable)
./link_grib.csh ../GFS/
ln -sf ungrib/Variable_Tables/Vtable.GFS Vtable

# First run geogrid to define the landuse
./geogrid.exe

# Now run ungrib.exe
./ungrib.exe

# Now run metgrid.exe
./metgrid.exe
####################################################
####################################################
# Now we run can run WRF if WPS was a sucess
echo "
###########################
#	Running WRF       #
###########################"

echo

# Go to run directory
cd ../WRF/run

# Remove old wrf runs
rm wrfinput_d01 wrfbdy_01 met_em* wrfout_d01_* wrfrst_d01*

# First link to the new met_em files
ln -sf ../../WPS/met_em.d0* .

# Now run real.exe
./real.exe

# Now run wrf.exe using 36 processors
mpirun -n 36 ./wrf.exe

echo "
###########################
#	WRF Done          #
###########################"

echo

echo "
###########################
#	Plotting          #
###########################"

echo

wrf=$(ls wrfout_d01_????-??-??_??:00:00*)

################################
# Get the data ready for plotting in GMT. We have to convert the data
# using CDO as GMT as troubles with WRF's native grid. The data is
# converted to a Cartesian system, which is actually very convenient
# and means we can even use R later for plotting.
################################
for i in $wrf
do
    cdo selname,TSK       $i k_$i &
    cdo selname,WSPD10MAX $i w_$i &
    cdo selname,AFWA_CAPE $i cp_$i &
    cdo selname,REFD_COM  $i rf_$i &
    cdo selname,RAINC     $i rn_$i &
    cdo selname,RAINNC    $i rnc_$i &
    cdo selname,AFWA_ZLFC $i lc_$i &
    cdo selname,AFWA_MSLP $i ps_$i &
    cdo selname,AFWA_CLOUD $i frac_$i &
done

wait

for i in $wrf
do
    cdo -addc,-273.15 k_$i c_$i &
    cdo add rn_$i rnc_$i r_$i &
    cdo divc,100 ps_$i sfcp_$i &
    cdo divc,25 frac_$i cf_$i &
done

wait

for i in $wrf
do
    cdo gmtxyz c_$i  > c_$i.gmt &
    cdo gmtxyz w_$i  > w_$i.gmt &
    cdo gmtxyz cp_$i > cp_$i.gmt &
    cdo gmtxyz rf_$i > rf_$i.gmt &
    cdo gmtxyz r_$i  > r_$i.gmt &
    cdo gmtxyz lc_$i  > lc_$i.gmt &
    cdo gmtxyz sfcp_$i  > sfcp_$i.gmt &
    cdo gmtxyz cf_$i  > cf_$i.gmt &
done

wait

#########################################
# Use GMT to plot the data on the Mercator projection. In WRF
# namelist.input we use the Mercator projection as well
#########################################
coord=(9/40/-40/-15)

#for i in $wrf
#do
#    gmt xyz2grd -R$coord -I28m -D+zDbZ rf_$i.gmt -Gnew.nc
#    gmt surface rf_$i.gmt -R$coord -I28m -Ggrd.nc 
#done

# Make the color scales
gmt makecpt    -Cplasma -T0/70/7          > refd.cpt
gmt makecpt    -Cplasma -T0/80/8          > rain.cpt
gmt makecpt    -Cplasma -T0/2000/250      > cape.cpt
gmt makecpt    -Cplasma -T-10/65/2.5      > tmp.cpt
gmt makecpt    -Cplasma -T0/20/0.8        > wspd.cpt
gmt makecpt    -Cplasma -T-10/7000/250    > lfc.cpt
gmt makecpt    -Cplasma -T0/1/0.05        > cf.cpt

# Plot temperature (TSK)
for i in $wrf
do
    gmt psbasemap  -R$coord -JM18 -Xc -Yc -Ba0 -K                         > t_$i.ps
    gmt pscontour  -R -J -I -Ctmp.cpt c_$i.gmt -O -K                     >> t_$i.ps
    gmt pscoast    -R -J -Df -Sskyblue -N1/white -Wfaint -B5g0 -O -K     >> t_$i.ps
    gmt pscontour  -R -J -Wthinnest,-- sfcp_$i.gmt -C2 -A2+f8 -T+d10+lLH -O -K  >> t_$i.ps
    gmt psxy       ZAF_adm1.gmt -R -J -W0.15,white -V -O -K              >> t_$i.ps
    gmt psxy       -R -J towns.dat -W -Sc0.1 -Gred -O -K                 >> t_$i.ps
    gmt pstext     -R -J towns.dat -X0.10 -Y0 -O -F+fwhite -K            >> t_$i.ps
    echo "$i" | gmt pstext -R -J -F+cTR+f18p,Bold -Gwhite -Wthick -D-7.95/-0.25 -O -K >> t_$i.ps
    gmt psscale    -Ctmp.cpt -R -J -G-10/45 -Dx1.25c/6c+w5c/0.5c+jTC -Bx5+l"Temperature" -By+lc -O >> t_$i.ps
done

# Plot windspeed max (WSPD10MAX)
for i in $wrf
do
    gmt psbasemap  -R$coord -JM18 -Xc -Yc -Ba0 -K                         > w_$i.ps
    gmt pscontour  -R -J -I -Cwspd.cpt w_$i.gmt -O -K                    >> w_$i.ps
    gmt pscoast    -R -J -Df -Sskyblue -N1/white -Wfaint -B5g0 -O -K     >> w_$i.ps
    gmt pscontour  -R -J -Wthinnest,-- sfcp_$i.gmt -C2 -A2+f8 -T+d10+lLH -O -K  >> w_$i.ps
    gmt psxy       ZAF_adm1.gmt -R -J -W0.15,white -V -O -K              >> w_$i.ps
    gmt psxy       -R -J towns.dat -W -Sc0.1 -Gred -O -K                 >> w_$i.ps
    gmt pstext     -R -J towns.dat -X0.10 -Y0 -F+fwhite -O -K            >> w_$i.ps
    echo "$i" | gmt pstext -R -J -F+cTR+f18p,Bold -Gwhite -Wthick -D-7.95/-0.25 -O -K >> w_$i.ps
    gmt psscale    -Cwspd.cpt -R -J -Dx1.25c/6c+w5c/0.5c+jTC -Bx1.5+l"Windspeed" -By+lm/s -O >> w_$i.ps
done

# Plot radar composite ref (REFD_COM)
for i in $wrf
do
    gmt psbasemap  -R$coord -JM18 -Xc -Yc -Ba0 -K                         > rf_$i.ps
    gmt pscontour  -R -J -I -Crefd.cpt rf_$i.gmt -O -K                   >> rf_$i.ps
    gmt pscoast    -R -J -Df -Sskyblue -N1/white -Wfaint -B5g0 -O -K     >> rf_$i.ps
    gmt pscontour  -R -J -Wthinnest,-- sfcp_$i.gmt -C2 -A2+f8 -T+d10+lLH -O -K  >> rf_$i.ps
    gmt psxy       ZAF_adm1.gmt -R -J -W0.15,white -V -O -K              >> rf_$i.ps
    gmt psxy       -R -J towns.dat -W -Sc0.1 -Gred -O -K                 >> rf_$i.ps
    gmt pstext     -R -J towns.dat -X0.10 -Y0 -F+fwhite -O -K            >> rf_$i.ps
    echo "$i" | gmt pstext -R -J -F+cTR+f18p,Bold -Gwhite -Wthick -D-7.95/-0.25 -O -K >> rf_$i.ps
    gmt psscale    -Crefd.cpt -R -J -Dx1.25c/6c+w5c/0.5c+jTC -Bx8+l"Reflectivity" -By+ldBz -O >> rf_$i.ps
done

# Plot rainfall (AFWA_RAIN)
for i in $wrf
do
    gmt psbasemap  -R$coord -JM18 -Xc -Yc -Ba0 -K                         > r_$i.ps
    gmt pscontour  -R -J -I -Crain.cpt r_$i.gmt -O -K                    >> r_$i.ps
    gmt pscoast    -R -J -Df -Sskyblue -N1/white -Wfaint -B5g0 -O -K     >> r_$i.ps
    gmt pscontour  -R -J -Wthinnest,-- sfcp_$i.gmt -C2 -A2+f8 -T+d10+lLH -O -K  >> r_$i.ps
    gmt psxy       ZAF_adm1.gmt -R -J -W0.15,white -V -O -K              >> r_$i.ps
    gmt psxy       -R -J towns.dat -W -Sc0.1 -Gred -O -K                 >> r_$i.ps
    gmt pstext     -R -J towns.dat -X0.10 -Y0 -F+fwhite -O -K            >> r_$i.ps
    echo "$i" | gmt pstext -R -J -F+cTR+f18p,Bold -Gwhite -Wthick -D-7.95/-0.25 -O -K >> r_$i.ps
    gmt psscale    -Crain.cpt -R -J -Dx1.25c/6c+w5c/0.5c+jTC -Bx10+l"Rainfall" -By+lmm -O >> r_$i.ps
done

# Plot LFC (AFWA_LFC)
for i in $wrf
do
    gmt psbasemap  -R$coord -JM18 -Xc -Yc -Ba0 -K                     > lc_$i.ps
    gmt pscontour  -R -J -I -Clfc.cpt lc_$i.gmt -O -K                >> lc_$i.ps
    gmt pscoast    -R -J -Df -Sskyblue -N1/white -Wfaint -B5g0 -O -K >> lc_$i.ps
    gmt pscontour  -R -J -Wthinnest,-- sfcp_$i.gmt -C2 -A2+f8 -T+d10+lLH -O -K  >> lc_$i.ps
    gmt psxy       ZAF_adm1.gmt -R -J -W0.15,white -V -O -K         >> lc_$i.ps
    gmt psxy       -R -J towns.dat -W -Sc0.1 -Gred -O -K            >> lc_$i.ps
    gmt pstext     -R -J towns.dat -X0.10 -Y0 -F+fwhite -O -K       >> lc_$i.ps
    echo "$i" | gmt pstext -R -J -F+cTR+f18p,Bold -Gwhite -Wthick -D-7.95/-0.25 -O -K >> lc_$i.ps
    gmt psscale    -Clfc.cpt -R -J -Dx1.25c/6c+w5c/0.5c+jTC -Bx1000+l"LFC" -By+lm -O >> lc_$i.ps
done

# Plot Cloud Fraction (AFWA_CLOUD)
for i in $wrf
do
    gmt psbasemap  -R$coord -JM18 -Xc -Yc -Ba0 -K                     > cf_$i.ps
    gmt pscontour  -R -J -I -Ccf.cpt cf_$i.gmt -O -K                 >> cf_$i.ps
    gmt pscoast    -R -J -Df -Sskyblue -N1/white -Wfaint -B5g0 -O -K >> cf_$i.ps
    gmt pscontour  -R -J -Wthinnest,-- sfcp_$i.gmt -C2 -A2+f8 -T+d10+lLH -O -K  >> cf_$i.ps
    gmt psxy       ZAF_adm1.gmt -R -J -W0.15,white -V -O -K         >> cf_$i.ps
    gmt psxy       -R -J towns.dat -W -Sc0.1 -Gred -O -K            >> cf_$i.ps
    gmt pstext     -R -J towns.dat -X0.10 -Y0 -F+fwhite -O -K       >> cf_$i.ps
    echo "$i" | gmt pstext -R -J -F+cTR+f18p,Bold -Gwhite -Wthick -D-7.95/-0.25 -O -K >> cf_$i.ps
    gmt psscale    -Ccf.cpt -R -J -G0/1 -Dx1.25c/6c+w5c/0.5c+jTC -Bx0.1+l"Cloud Fraction" -O >> cf_$i.ps
done


# Plot cape (AFWA_CAPE)
for i in $wrf
do
    gmt psbasemap  -R$coord -JM18 -Xc -Yc -Ba0 -K                         > cp_$i.ps
    gmt pscontour  -R -J -I -Ccape.cpt cp_$i.gmt -di100 -do200 -O -K     >> cp_$i.ps
    gmt pscoast    -R -J -Df -Sskyblue -N1/white -Wfaint -B5g0 -O -K     >> cp_$i.ps
    gmt pscontour  -R -J -Wthinnest,-- sfcp_$i.gmt -C2 -A2+f8 -T+d10+lLH -O -K  >> cp_$i.ps
    gmt psxy       ZAF_adm1.gmt -R -J -W0.15,white -V -O -K              >> cp_$i.ps
    gmt psxy       -R -J towns.dat -W -Sc0.1 -Gred -O -K                 >> cp_$i.ps
    gmt pstext     -R -J towns.dat -X0.10 -Y0 -F+fwhite -O -K            >> cp_$i.ps
    echo "$i" | gmt pstext -R -J -F+cTR+f18p,Bold -Gwhite -Wthick -D-7.95/-0.25 -O -K >> cp_$i.ps
    gmt psscale    -Ccape.cpt -R -J -Dx1.25c/6c+w5c/0.5c+jTC -Bx250+l"CAPE" -By+lj/kg -O >> cp_$i.ps
done

# Convert all the data to a png
for i in $wrf
do
    gmt psconvert   t_${i}.ps -A -P -Tg &
    gmt psconvert   w_${i}.ps -A -P -Tg &
    gmt psconvert   r_${i}.ps -A -P -Tg &
    gmt psconvert   rf_${i}.ps -A -P -Tg &
    gmt psconvert   cp_${i}.ps -A -P -Tg &
    gmt psconvert   lc_${i}.ps -A -P -Tg &
    gmt psconvert   cf_${i}.ps -A -P -Tg &
done

wait

# Do some quick cleaning  
rm -rf wrfpng/ skewtpng/
mkdir wrfpng
mv *wrfout*png wrfpng/
rm rnc_* rn_* ps_* sfcp_* k_wrf* w_w*  c_w* cp_w* r_w* rf_w* t_w*
rm cf_w* frac_w* lc_w* *ps *cnv *wrfout*gmt *nc skd*png

exit 0
{% endhighlight %}

Now lets make this even more complicated

{% highlight bash %}
#!/bin/bash

cd WRF/run/

################################
# Use the skewt python package to plot skewt's
# This loop might crash in parallel, rather do it in sections.
################################
wrf=$(ls wrfout_d01_????-??-??_??:00:00*)

################################
# South-Africa
################################
mfk="--lat -25.7830 --lon 25.3300"
pta="--lat -25.7330 --lon 28.1830"
irn="--lat -25.9100 --lon 28.2111"
alx="--lat -28.5670 --lon 16.5330"
upt="--lat -28.4136 --lon 21.2597"
blm="--lat -29.1000 --lon 26.3000"
bet="--lat -28.2500 --lon 28.3333"
spr="--lat -29.6719 --lon 17.8875"
dea="--lat -30.6747 --lon 23.9992"
pol="--lat -23.8962 --lon 29.4486"
dur="--lat -29.6017 --lon 31.1300"
cpt="--lat -33.9700 --lon 18.6000"
peb="--lat -33.9844 --lon 25.6108"
sul="--lat -32.4101 --lon 20.6705"
mata="--lat -25.7615 --lon 20.0113"
################################

for i in $wrf
do
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_irn_$i.png ${irn} -f $i &
done

wait

for i in $wrf
do
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_mfk_$i.png ${mfk} -f $i &
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_irn_$i.png ${irn} -f $i &
done

wait

for i in $wrf
do
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_alx_$i.png ${alx} -f $i &
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_upt_$i.png ${upt} -f $i &
done

wait

for i in $wrf
do
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_blm_$i.png ${blm} -f $i &
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_mat_$i.png ${mata} -f $i &
done

wait

for i in $wrf
do
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_bet_$i.png ${bet} -f $i &
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_spr_$i.png ${spr} -f $i &
done

wait

for i in $wrf
do
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_dea_$i.png ${dea} -f $i &
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_pol_$i.png ${pol} -f $i &
done

wait

for i in $wrf
do
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_dur_$i.png ${dur} -f $i &
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_cpt_$i.png ${cpt} -f $i &
done

wait

for i in $wrf
do
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_peb_$i.png ${peb} -f $i &
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_sul_$i.png ${sul} -f $i &
done

wait

################################
## International
################################
# Namibia
luderitz="--lat -26.6475 --lon 15.1536"
windhoek="--lat -22.5609 --lon 17.0657"
rundu="--lat -17.9146 --lon 19.7838"
goageb="--lat -23.5603 --lon 15.0404"
sesfontein="--lat -19.1243 --lon 13.6175"
################################

for i in $wrf
do
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_luderitz_$i.png ${luderitz} -f $i &
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_windhoek_$i.png ${windhoek} -f $i &
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_rundu_$i.png ${rundu} -f $i &
done

wait

for i in $wrf
do
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_goageb_$i.png ${goageb} -f $i &
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_sesfontein_$i.png ${sesfontein} -f $i &
done

wait

################################
# Botswana
################################
gaberone="--lat -24.6282 --lon 25.9231"
ghanzi="--lat -21.6939 --lon 21.6491"
francistown="--lat -21.1661 --lon 27.5144"
maun="--lat -19.9953 --lon 23.4181"
################################

for i in $wrf
do
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_gaberone_$i.png ${gaberone} -f $i &
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_ghanzi_$i.png ${ghanzi} -f $i &
done

wait

for i in $wrf
do
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_francistown_$i.png ${francistown} -f $i &
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_maun_$i.png ${maun} -f $i &
done

wait

################################
# Zambia
################################
lusaka="--lat -15.4196 --lon 28.2831"
livingstone="--lat -17.8250 --lon 25.8285"
################################

for i in $wrf
do
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_lusaka_$i.png ${lusaka} -f $i &
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_livingstone_$i.png ${livingstone} -f $i &
done

wait

################################
# Zimbabwe
################################
harare="--lat -17.8252 --lon 31.0335"
bulawayo="--lat -20.1325 --lon 28.6265"
################################

for i in $wrf
do
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_harare_$i.png ${harare} -f $i &
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_bulawayo_$i.png ${bulawayo} -f $i &
done

wait

################################
# Mozambique
################################
maseru="--lat -29.3151 --lon 27.4869"
beira="--lat -19.8305 --lon 34.8430"
################################

for i in $wrf
do
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_maseru_$i.png ${maseru} -f $i &
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_beira_$i.png ${beira} -f $i &
done

wait

################################
# Lesotho and Swaziland
################################
mbabane="--lat -26.3261 --lon 31.1461"
maputu="--lat -25.9732 --lon 32.5720"
################################

for i in $wrf
do
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_mbabane_$i.png ${mbabane} -f $i &
  /usr/bin/python /home/henno/.local/bin/skewt wrf skd_maputu_$i.png ${maputu} -f $i &
done

wait

for i in $wrf
do
    mogrify -density 150 -format png skd_[a-e]*pdf &
    mogrify -density 150 -format png skd_[f-j]*pdf &
done

wait

for i in $wrf
do
    mogrify -density 150 -format png skd_[k-o]*pdf &
    mogrify -density 150 -format png skd_[p-t]*pdf &
    mogrify -density 150 -format png skd_[u-z]*pdf &
done

wait

#rm -rf skewtpng/
rm *pdf
mkdir skewtpng
mv skd*png skewtpng/

###################################################################
# Now we need to get the wrf png to the webserver
###################################################################
for i in 13 14 15 16 17 19 20 21 22 23 01 02 03 04 05 07 08 09 10 11
do
	rm skewtpng/*$i:??:??.png
done

rm /home/henno/crggithub.github.io/assets/images/wrf/*png 
rm /home/henno/crggithub.github.io/assets/images/skwt/*png 

cp wrfpng/*png /home/henno/crggithub.github.io/assets/images/wrf/
cp skewtpng/*png /home/henno/crggithub.github.io/assets/images/skwt/ 

cd /home/henno/crggithub.github.io/wrf/

wrf=$(ls ../assets/images/wrf/*)
wrfnr=$(ls  ../assets/images/wrf/cp_* | wc -l)

rm *lst
rm *html *md

for i in $wrf
do
    echo "'$i'," | sed 's/\.\.//g' | grep "w_wrfout" >> wrfwind.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "t_wrfout" >> wrftemp.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "r_wrfout" >> wrfrainfall.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "rf_wrfout" >> wrfradar.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "cp_wrfout" >> wrfcape.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "lc_wrfout" >> wrflfc.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "cf_wrfout" >> wrfcf.lst
done

rainpng=$(cat wrfrainfall.lst)
temppng=$(cat wrftemp.lst)
capepng=$(cat wrfcape.lst)
radarpng=$(cat wrfradar.lst)
windpng=$(cat wrfwind.lst)
lfcpng=$(cat wrflfc.lst)
cfpng=$(cat wrfcf.lst)

########################################################
cat > wrfcf.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrflfc.html
---

<h1>WRF CLoud Fraction </h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$wrfnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$cfpng];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfcf.md << EOF
<h1>WRF  Cloud Fraction </h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$wrfnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$cfpng];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF


########################################################
cat > wrflfc.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrflfc.html
---

<h1>WRF Level of Free Convection (LFC)</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$wrfnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$lfcpng];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrflfc.md << EOF
<h1>WRF Level of Free Convection (LFC)</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$wrfnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$lfcpng];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF
####################################################
cat > wrfrainfall.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfrainfall.html
---

<h1>WRF Accumulated Precipitation</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$wrfnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$rainpng];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfrainfall.md << EOF
<h1>WRF Accumulated Precipitation</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$wrfnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$rainpng];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF
####################################################
cat > wrfradar.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfradar.html
---

<h1>WRF Simulated Radar</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$wrfnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$radarpng];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfradar.md << EOF
<h1>WRF Simulated Radar</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$wrfnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$radarpng];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF
####################################################
cat > wrfcape.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfcape.html
---

<h1>WRF Simulated CAPE</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$wrfnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$capepng];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfcape.md << EOF
<h1>WRF Simulated CAPE</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$wrfnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$capepng];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF
####################################################
cat > wrfwindspeed.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfwindspeed.html
---

<h1>WRF Simulated Max Wind Gust</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$wrfnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$windpng];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfwindspeed.md << EOF
<h1>WRF Simulated Max Wind Gust</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$wrfnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$windpng];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF
####################################################
cat > wrftemp.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrftemp.html
---

<h1>WRF Simulated Temperature</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$wrfnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$temppng];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrftemp.md << EOF
<h1>WRF Simulated Temperature</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$wrfnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$temppng];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

#########################################################
# Skewt's
#########################################################
skwt=$(ls ../assets/images/skwt/*)
skwtnr=$(ls  ../assets/images/skwt/skd_alx* | wc -l)

#########################################################
# South Africa
#########################################################
for i in $skwt
do
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_irn" >> irene.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_cpt" >> cpt.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_dur" >> dur.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_upt" >> upt.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_blm" >> blm.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_mfk" >> mafikeng.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_alx" >> alexander.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_pol" >> polokwane.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_bet" >> bethlehem.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_spr" >> springbok.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_peb" >> portelizabeth.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_dea" >> deaar.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_sul" >> sutherland.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_mat" >> mata.lst
done

irene=$(cat irene.lst)
cpt=$(cat cpt.lst)
dur=$(cat dur.lst)
upt=$(cat upt.lst)
blm=$(cat blm.lst)
mafikeng=$(cat mafikeng.lst)
alexander=$(cat alexander.lst)
polokwane=$(cat polokwane.lst)
bethlehem=$(cat bethlehem.lst)
springbok=$(cat springbok.lst)
portelizabeth=$(cat portelizabeth.lst)
deaar=$(cat deaar.lst) 
sutherland=$(cat sutherland.lst) 
mata=$(cat mata.lst) 

########################################################
cat > wrfskwt_mata.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_mata.html
---

<h1>Mata-Mata Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$mata];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_mata.md << EOF
<h1>Mata-Mata Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$mata];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

########################################################
cat > wrfskwt_sutherland.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_sutherland.html
---

<h1>Sutherland Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$sutherland];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_sutherland.md << EOF
<h1>Sutherland Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$sutherland];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

########################################################
cat > wrfskwt_portelizabeth.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_portelizabeth.html
---

<h1>Port-Elizabeth Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$portelizabeth];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_portelizabeth.md << EOF
<h1>Port-Elizabeth Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$portelizabeth];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF
########################################################
cat > wrfskwt_bethlehem.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_bethlehem.html
---

<h1>Bethlehem Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$bethlehem];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_bethlehem.md << EOF
<h1>Bethlehem Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$bethlehem];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

########################################################
cat > wrfskwt_polokwane.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_polokwane.html
---

<h1>Polokwane Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$polokwane];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_polokwane.md << EOF
<h1>Polokwane Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$polokwane];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

########################################################
cat > wrfskwt_alexander.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_alexander.html
---

<h1>Alexander Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$alexander];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_alexander.md << EOF
<h1>Alexander Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$alexander];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

########################################################
cat > wrfskwt_deaar.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_deaar.html
---

<h1>De-Aar Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$deaar];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_deaar.md << EOF
<h1>De-Aar Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$deaar];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

########################################################
cat > wrfskwt_springbok.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_springbok.html
---

<h1>Springbok Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$springbok];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_springbok.md << EOF
<h1>Springbok Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$springbok];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

########################################################
cat > wrfskwt_mafikeng.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_mafikeng.html
---

<h1>Mafikeng Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$mafikeng];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_mafikeng.md << EOF
<h1>Mafikeng Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$mafikeng];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

########################################################
cat > wrfskwt_irene.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_irene.html
---

<h1>Irene Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$irene];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_irene.md << EOF
<h1>Irene Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$irene];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF
#########################################
cat > wrfskwt_cpt.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_cpt.html
---

<h1>Cape Town Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$cpt];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_cpt.md << EOF
<h1>Cape Town Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$cpt];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF
#########################################
cat > wrfskwt_durban.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_durban.html
---

<h1>Durban Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$dur];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_durban.md << EOF
<h1>Durban Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$dur];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF
#########################################
cat > wrfskwt_upington.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_upington.html
---

<h1>Upington Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$upt];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_upington.md << EOF
<h1>Upington Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$upt];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF
#########################################
cat > wrfskwt_bloemfontein.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_bloemfontein.html
---

<h1>Bloemfontein Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$blm];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_bloemfontein.md << EOF
<h1>Bloemfontein Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$blm];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

#########################################################
# Botswana
#########################################################

for i in $skwt
do
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_ghanzi" >> ghanzi.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_gaberone" >> gaberone.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_maun" >> maun.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_francistown" >> francistown.lst
done

gaberone=$(cat gaberone.lst)
ghanzi=$(cat ghanzi.lst)
maun=$(cat maun.lst)
francistown=$(cat francistown.lst)

cat > wrfskwt_francistown.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_francistown.html
---

<h1>Francistown Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$francistown];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_francistown.md << EOF
<h1>Francistown Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$francistown];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF
##################################################
cat > wrfskwt_maun.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_maun.html
---

<h1>Maun Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$maun];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_maun.md << EOF
<h1>Maun Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$maun];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF
##################################################
cat > wrfskwt_ghanzi.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_ghanzi.html
---

<h1>Ghanzi Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$ghanzi];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_ghanzi.md << EOF
<h1>Ghanzi Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$ghanzi];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF
##################################################
cat > wrfskwt_gaberone.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_gaberone.html
---

<h1>Gaberone Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$gaberone];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_gaberone.md << EOF
<h1>Gaberone Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$gaberone];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

#########################################################
# Namibia
#########################################################

for i in $skwt
do
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_windhoek" >> windhoek.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_luderitz" >> luderitz.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_rundu" >> rundu.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_goageb" >> goageb.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_sesfontein" >> sesfontein.lst
done

windhoek=$(cat windhoek.lst)
luderitz=$(cat luderitz.lst)
rundu=$(cat rundu.lst)
goageb=$(cat goageb.lst)
sesfontein=$(cat sesfontein.lst)

cat > wrfskwt_sesfontein.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_sesfontein.html
---

<h1>Sesfontein Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$sesfontein];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_sesfontein.md << EOF
<h1>Sesfontein Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$sesfontein];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF
##################################################
cat > wrfskwt_windhoek.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_windhoek.html
---

<h1>Windhoek Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$windhoek];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_windhoek.md << EOF
<h1>Windhoek Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$windhoek];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF
##################################################
cat > wrfskwt_luderitz.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_luderitz.html
---

<h1>Luderitz Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$luderitz];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_luderitz.md << EOF
<h1>Luderitz Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$luderitz];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF
##################################################
cat > wrfskwt_goageb.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_goageb.html
---

<h1>Goageb Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$goageb];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_goageb.md << EOF
<h1>Goageb Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$goageb];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF
##################################################
cat > wrfskwt_rundu.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_rundu.html
---

<h1>Rundu Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$rundu];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_rundu.md << EOF
<h1>Rundu Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$rundu];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

#########################################################
# Zimbabwe
#########################################################

for i in $skwt
do
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_harare" >> harare.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_bulawayo" >> bulawayo.lst
done

bulawayo=$(cat bulawayo.lst)
harare=$(cat harare.lst)

cat > wrfskwt_harare.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_harare.html
---

<h1>Harare Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$harare];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_harare.md << EOF
<h1>Harare Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$harare];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF
##################################################
cat > wrfskwt_bulawayo.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_bulawayo.html
---

<h1>Bulawayo Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$bulawayo];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_bulawayo.md << EOF
<h1>Bulawayo Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$bulawayo];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

#########################################################
# Mozambique
#########################################################
for i in $skwt
do
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_maputu" >> maputu.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_beira" >> beira.lst
done

beira=$(cat beira.lst)
maputu=$(cat maputu.lst)

cat > wrfskwt_maputu.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_maputu.html
---

<h1>Maputu Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$maputu];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_maputu.md << EOF
<h1>Maputu Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$maputu];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF
##################################################
cat > wrfskwt_beira.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_beira.html
---

<h1>Beira Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$beira];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_beira.md << EOF
<h1>Beira Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$beira];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

#########################################################
# Zambia
#########################################################
for i in $skwt
do
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_lusaka" >> lusaka.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_livingstone" >> livingstone.lst
done

lusaka=$(cat lusaka.lst)
livingstone=$(cat livingstone.lst)

cat > wrfskwt_livingstone.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_livingstone.html
---

<h1>Livingstone Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$livingstone];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_livingstone.md << EOF
<h1>Livingstone Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$livingstone];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF
#########################################################
cat > wrfskwt_lusaka.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_lusaka.html
---

<h1>Lusaka Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$lusaka];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_lusaka.md << EOF
<h1>Lusaka Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$lusaka];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF
#########################################################
# Lesotho and Swaziland
#########################################################
for i in $skwt
do
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_mbabane" >> mbabane.lst
    echo "'$i'," | sed 's/\.\.//g' | grep "skd_maseru" >> maseru.lst
done

maseru=$(cat maseru.lst)
mbabane=$(cat mbabane.lst)

cat > wrfskwt_mbabane.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_mbabane.html
---

<h1>Mbabane Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$mbabane];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_mbabane.md << EOF
<h1>Mbabane Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$mbabane];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF
##################################################
cat > wrfskwt_maseru.html << EOF
---
layout: page
tagline: Nort-West University Operational WRF
permalink: /wrfskwt_maseru.html
---

<h1>Maseru Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$maseru];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

cat > wrfskwt_maseru.md << EOF
<h1>Maseru Sounding</h1>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$skwtnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$maseru];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>
EOF

#####################################################################
cat > wrf.md << EOF
---
layout: page
title: NWU-WRF
tagline: North-West University Operational WRF
permalink: /wrf.html
---

**The Weather Research and Forecasting Model Version (WRFV) 4.0**,
Microphysics=New Thompson, *et.al* (8),
Longwave Radiation=RRTMG scheme (4),
Shortwave Radiation=RRTMG scheme (4),
Land Surface=Noah Land Surface Model (2),
Planetary Boundary layer=Yonsei University scheme (1),
Cumulus Parameterization=Grell-Freitas (3),
Model Vertical Levels=34

#### Initialization Strategy
![forecast_strat]({{ "/assets/images/wrf_forecast.png" | absolute_url }})

---

<html>
<head>
<script>
function startTime() {
  var today = new Date();
  var h = today.getUTCHours();
  var m = today.getUTCMinutes();
  var s = today.getUTCSeconds();
  m = checkTime(m);
  s = checkTime(s);
  document.getElementById('txt').innerHTML =
  h + ":" + m + ":" + s;
  var t = setTimeout(startTime, 500);
}
function checkTime(i) {
  if (i < 10) {i = "0" + i};  // add zero in front of numbers < 10
  return i;
}
</script>
</head>

<body onload="startTime()">
The current UTC time is:
<div id="txt"></div>
</body>

</html>

---

## Forecasts 
Click links to expand

[Precipitation]({{ "/wrf/wrfrainfall.html" | absolute_url }}) ||
[Radar]({{ "/wrf/wrfradar.html" | absolute_url }}) ||
[Maximum Wind Gust]({{ "/wrf/wrfwindspeed.html" | absolute_url }}) ||
[CAPE]({{ "/wrf/wrfcape.html" | absolute_url }}) ||
[LFC]({{ "/wrf/wrflfc.html" | absolute_url }}) ||
[Cloud Fraction]({{ "/wrf/wrfcf.html" | absolute_url }}) ||
[Temperature]({{ "/wrf/wrftemp.html" | absolute_url }})

<h3>WRF Simulated CAPE</h3>
<p>Drag the slider to change the time</p>

<div class="slidecontainer">
<input oninput='setImage(this)' class="slider" type="range" min="0" max="$wrfnr" value="0" step="1" />
<img id='img'/>
</div>

<script>
var img = document.getElementById('img');
var img_array = [$capepng];
function setImage(obj)
{
        var value = obj.value;
        img.src = img_array[value];

}
</script>

### Soundings 
Click city names to expand

<img src="/assets/images/sounding_locations_2.png" alt="" usemap="#map" />
<map name="map">
    <area shape="rect" coords="397, 278, 450, 292" href="https://crggithub.github.io/wrf/wrfskwt_mafikeng.html" alt="mafikeng" title="Mafikeng" />
    <area shape="rect" coords="410, 247, 468, 260" href="https://crggithub.github.io/wrf/wrfskwt_gaberone.html" alt="gaberone" title="Gaberone" />
    <area shape="rect" coords="496, 225, 556, 241" href="https://crggithub.github.io/wrf/wrfskwt_polokwane.html" alt="polokwane" title="Polokwane" />
    <area shape="rect" coords="624, 122, 661, 139" href="https://crggithub.github.io/wrf/wrfskwt_beira.html" alt="beira" title="Beira" />
    <area shape="rect" coords="469, 13, 514, 28" href="https://crggithub.github.io/wrf/wrfskwt_lusaka.html" alt="lusaka" title="Lusaka" />
    <area shape="rect" coords="532, 72, 576, 88" href="https://crggithub.github.io/wrf/wrfskwt_harare.html" alt="harare" title="Harare" />
    <area shape="rect" coords="476, 130, 532, 145" href="https://crggithub.github.io/wrf/wrfskwt_bulawayo.html" alt="bulawayo" title="Bulawayo" />
    <area shape="rect" coords="577, 280, 621, 296" href="https://crggithub.github.io/wrf/wrfskwt_maputu.html" alt="maputu" title="Maputu" />
    <area shape="rect" coords="537, 290, 568, 307" href="https://crggithub.github.io/wrf/wrfskwt_mbabane.html" alt="mbabane" title="Mbabane" />
    <area shape="rect" coords="459, 277, 514, 303" href="https://crggithub.github.io/wrf/wrfskwt_irene.html" alt="irene" title="Irene" />
    <area shape="rect" coords="466, 342, 532, 358" href="https://crggithub.github.io/wrf/wrfskwt_bethlehem.html" alt="bethlehem" title="Bethlehem" />
    <area shape="rect" coords="459, 373, 490, 388" href="https://crggithub.github.io/wrf/wrfskwt_maseru.html" alt="maseru" title="Maseru" />
    <area shape="rect" coords="419, 365, 445, 381" href="https://crggithub.github.io/wrf/wrfskwt_bloemfontein.html" alt="bloemfontein" title="Bloemfontein" />
    <area shape="rect" coords="297, 347, 352, 361" href="https://crggithub.github.io/wrf/wrfskwt_upington.html" alt="upington" title="Upington" />
    <area shape="rect" coords="536, 379, 581, 394" href="https://crggithub.github.io/wrf/wrfskwt_durban.html" alt="durban" title="Durban" />
    <area shape="rect" coords="364, 409, 411, 426" href="https://crggithub.github.io/wrf/wrfskwt_deaar.html" alt="deaar" title="De-Aar" />
    <area shape="rect" coords="404, 502, 480, 518" href="https://crggithub.github.io/wrf/wrfskwt_portelizabeth.html" alt="portelizabeth" title="Port-Elizabeth" />
    <area shape="rect" coords="235, 502, 298, 518" href="https://crggithub.github.io/wrf/wrfskwt_cpt.html" alt="capetown" title="Cape-Town" />
    <area shape="rect" coords="217, 382, 276, 396" href="https://crggithub.github.io/wrf/wrfskwt_springbok.html" alt="springbok" title="Springbok" />
    <area shape="rect" coords="184, 351, 245, 367" href="https://crggithub.github.io/wrf/wrfskwt_alexander.html" alt="alexander" title="Alexander" />
    <area shape="rect" coords="306, 170, 352, 186" href="https://crggithub.github.io/wrf/wrfskwt_ghanzi.html" alt="ghanzi" title="Ghanzi" />
    <area shape="rect" coords="151, 298, 200, 315" href="https://crggithub.github.io/wrf/wrfskwt_luderitz.html" alt="luderitz" title="Luderitz" />
    <area shape="rect" coords="148, 218, 199, 235" href="https://crggithub.github.io/wrf/wrfskwt_goageb.html" alt="goageb" title="Goageb" />
    <area shape="rect" coords="195, 192, 257, 207" href="https://crggithub.github.io/wrf/wrfskwt_windhoek.html" alt="windhoek" title="Windhoek" />
    <area shape="rect" coords="258, 72, 309, 89" href="https://crggithub.github.io/wrf/wrfskwt_rundu.html" alt="rundu" title="Rundu" />
    <area shape="rect" coords="281, 454, 348, 475" href="https://crggithub.github.io/wrf/wrfskwt_sutherland.html" alt="sutherland" title="Sutherland" />
    <area shape="rect" coords="264, 271, 331, 296" href="https://crggithub.github.io/wrf/wrfskwt_mata.html" alt="matamata" title="Mata-Mata" />
    <area shape="rect" coords="444, 153, 517, 174" href="https://crggithub.github.io/wrf/wrfskwt_francistown.html" alt="francistown" title="Francistown" />
    <area shape="rect" coords="347, 123, 390, 145" href="https://crggithub.github.io/wrf/wrfskwt_maun.html" alt="maun" title="Maun" />
    <area shape="rect" coords="402, 68, 476, 90" href="https://crggithub.github.io/wrf/wrfskwt_livingstone.html" alt="livingstone" title="Livingstone" />
    <area shape="rect" coords="112, 100, 178, 121" href="https://crggithub.github.io/wrf/wrfskwt_sesfontein.html" alt="sesfontein" title="Sesfontein" />
</map>

#### South-Africa
[Alexandria]({{ "/wrf/wrfskwt_alexandria.html" | absolute_url }}) ||
[Bethlehem]({{ "/wrf/wrfskwt_bethlehem.html" | absolute_url }}) ||
[Bloemfontein]({{ "/wrf/wrfskwt_bloemfontein.html" | absolute_url }}) || 
[Cape Town]({{ "/wrf/wrfskwt_cpt.html" | absolute_url }}) ||
[De-Aar]({{ "/wrf/wrfskwt_deaar.html" | absolute_url }}) ||
[Durban]({{ "/wrf/wrfskwt_durban.html" | absolute_url }}) ||
[Irene]({{ "/wrf/wrfskwt_irene.html" | absolute_url }}) ||
[Upington]({{ "/wrf/wrfskwt_upington.html" | absolute_url }}) ||
[Mafikeng]({{ "/wrf/wrfskwt_mafikeng.html" | absolute_url }}) ||
[Polokwane]({{ "/wrf/wrfskwt_polokwane.html" | absolute_url }}) ||
[Port Elizabeth]({{ "/wrf/wrfskwt_portelizabeth.html" | absolute_url }}) ||
[Springbok]({{ "/wrf/wrfskwt_springbok.html" | absolute_url }}) ||
[Sutherland]({{ "/wrf/wrfskwt_sutherland.html" | absolute_url }}) ||
[Mata-Mata]({{ "/wrf/wrfskwt_mata.html" | absolute_url }})

#### Namibia
[Windhoek]({{ "/wrf/wrfskwt_windhoek.html" | absolute_url }}) ||
[Rundu]({{ "/wrf/wrfskwt_windhoek.html" | absolute_url }}) ||
[Luderitz]({{ "/wrf/wrfskwt_luderitz.html" | absolute_url }}) ||
[Goageb]({{ "/wrf/wrfskwt_goageb.html" | absolute_url }}) ||
[Rundu]({{ "/wrf/wrfskwt_Rundu.html" | absolute_url }}) || 
[Sesfontein]({{ "/wrf/wrfskwt_sesfontein.html" | absolute_url }}) 

#### Botswana
[Gaberone]({{ "/wrf/wrfskwt_gaberone.html" | absolute_url }}) ||
[Ghanzi]({{ "/wrf/wrfskwt_ghanzi.html" | absolute_url }}) ||
[Francistown]({{ "/wrf/wrfskwt_francistown.html" | absolute_url }}) ||
[Maun]({{ "/wrf/wrfskwt_muan.html" | absolute_url }})

#### Zimbabwe
[Harare]({{ "/wrf/wrfskwt_harare.html" | absolute_url }}) ||
[Bulawayo]({{ "/wrf/wrfskwt_bulawayo.html" | absolute_url }})

#### Mozambique
[Maputu]({{ "/wrf/wrfskwt_maputu.html" | absolute_url }}) ||
[Beira]({{ "/wrf/wrfskwt_beira.html" | absolute_url }})

#### Zambia
[Lusaka]({{ "/wrf/wrfskwt_lusaka.html" | absolute_url }}) ||
[Livingstone]({{ "/wrf/wrfskwt_livingstone.html" | absolute_url }}) 

#### Lesotho and Swaziland
[Maseru]({{ "/wrf/wrfskwt_maseru.html" | absolute_url }}) ||
[Mbabane]({{ "/wrf/wrfskwt_mbabane.html" | absolute_url }}) 

#### Practical considerations and limitations
+ The model is initialized using publicly available GFS data. The GFS forecasts are also viewable [here](http://www.lekwenaradar.co.za/forecast.html)
+ The model requires *spin-up* time to become numerically stable, the first hour of the forecast should be discarded
+ For observed Skew-T diagrams please visit the [University of Wyoming Upper-Air Database](http://weather.uwyo.edu/upperair/sounding.html)
+ Customized forecast products is available on request
+ Please note that SAWS is the only entity in South-Africa which can issue weather related warnings
EOF

mv wrf.md ../

exit 0
{% endhighlight %}

