---
layout: post
title:  "Getting WRF to work with ERA-Interim data"
date:   2017-09-20 12:43:29 +0200
categories: wrf era-interim climate
---

I actually started a blog as part of another class, but lets pretend
that never happened and mark this as the official start.

I’m slowly going to start putting myself out there, I’m trying
not to be a hypocrite – I preach open-source but I keep myself closed.

I’m in the process of running WRF. It’s not been without challenges though,
when running WRF locally compiling can be a major time consumer, you have
to know some GNU/Linux basics, which is actually pretty cool. Okay, I’m all
over the place, but let me write about my current problem and as the blog
evolves hopefully I can get more ordered.

I’m currently running WRF on a convective scale over the South-Africa
Highveld, the area is also home to Jo’burg and Pretoria, two of
South-Africa major cities, I’m doing this to try to understand hailstorms
better. WRF has various input datasets that can be used to initialize the
model, I’m specifically using ERA-Interim data, but the ERA data requires
some extra steps, I’m not going to try and give an in-depth explanation of
all the steps, but instead I’m just doing them here in the order that was
successful eventually. I also assume that you’ve already complied WRF
successfully and was to lazy to RTFM (like me) and used Google (like me).

Last thing, I use vim, but replace that with whatever you want, on a remote
machine nano and vi are good alternatives, Emacs is pretty cool (I’m super
slowly learning that) but I don’t know about its availability on all remote
computers.

First get the data ready in WPS:
{% highlight bash %}
$ cd wps/
$ ./geogrid.exe
$ ln -sf ungrib/Variable_Tables/Vtable.ERA-interim.ml Vtable
$ ./link_grib.csh ~/ei.oper.an.ml/201311/ei.oper.an.ml.regn128* ~/ei.oper.an.sfc/201311/ei.oper.an.sfc.regn128.sc.201311*
$ ./ungrib.exe
{% endhighlight %}

Create ecmwf_coeffs file:
{% highlight bash %}
$ touch ecmwf_coeffs #NOTE: Google for the ecmwf_coeffs contents, its just a table.
$ ./util/calc_ecmwf_p.exe
{% endhighlight %}

Look for PRES:2013-11-*

{% highlight bash %}
$ vim namelist.wps
&metgrid
  fg_name = ‘FILE’ ‘PRES’
$ ./metgrid.exe
{% endhighlight %}

Look for met_em.d0*

If this worked you will now go back and change directory to WRF:

{% highlight bash %}
$ cd ../WRFV7/test/em_real/
$ ln -sf ../../../WPS3.7/met_em.d0* .
$ ./real.exe
{% endhighlight %}

Look for wrfbdy_d01, wrfinput_do1, wrfinput_d02, …

{% highlight bash %}
$ ./wrf.exe
{% endhighlight %}

Look for wrfout_do1_2013* until complete for the run time series

Again, Google around for ecmwf_coeffs table I’m assuming you check,
double-check and triple check your namelist.wps and namelist.input. If
using more than two domains, check fourth time, its easy to miss something
when looking at to long.
