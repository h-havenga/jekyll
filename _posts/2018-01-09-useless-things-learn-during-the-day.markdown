---
layout: post
title:  "Usefull, useless things"
date:   2019-02-09 10:00:29 +0200
categories: things linux
---

Everyday I figure out small things that make life a little easier and don't fit
in my *useful one liners* post , I tend to forget them the moment I'm done
using it or implementing whatever I need it for. This could be anything from
latex to git to bash to vim and in most cases these are just little
conveniences. So I'll attempt to note these useless things here. 

### Adding Metadata to LaTeX pdf
This whole post was inspired by right clicking on my thesis and seeing that my
metadata is empty, the fix was pretty easy. Add this to your preamble:

{% highlight latex %}
\usepackage{hyperref}
\hypersetup{
    pdftitle={LaTeX is for cool kids},
    pdfsubject={Not Computer Science},
    pdfauthor={Henno Havenga},
    pdfkeywords={LaTeX, VIM, Debian, GNU, Linux}
}
{% endhighlight %}

### Plotting a tif file with GMT 
I needed to clip a [NASA Blue
Marble](https://visibleearth.nasa.gov/view_cat.php?categoryID=1484) tif file.
I wanted to use *gdal_tanslate* but a not so quick search yield
[*gdalwarp*](https://joeyklee.github.io/broc-cli-geo/guide/XX_raster_cropping_and_clipping.html)
as a simpler option. Also note that the default NASA projection is Plate Carrée
(JQ in GMT), this is useful to know if you want to draw borders over the NASA
data using GMT without thinking to much about conversions. To clip the data
I used gdalwarp and then GMT's psimage module to overlay the image on a map:

{% highlight bash %}
gdalwarp -te 15 59 38 71 blue_marble_infile.tif clipped_blue_marble_outfile.tif
{% endhighlight %}

{% highlight bash %}
gmt psbasemap -R15/38/59/71.5 -JQ20 -Xc -Yc -B5a0 -V -K > image_map.ps
gmt psimage clipped_blue_marble_outfile.tif -DjCM+w20/11.1 -R -J -O -K -V >> image_map.ps
{% endhighlight %}

### Linking to most recent EUMETSAT products in markdown
In playing around with this site I thought about make a page dedicated weather
stuff, it was pretty easy to link directly to EUMETSAT products with markdown
by just copying the image link like this:

{% highlight markdown %}
    <center> <td align="center" valign="center"> <img
    SRC="https://eumetview.eumetsat.int/static-images/latestImages/EUMETSAT_MSG_IR108Color_SouthernAfrica.jpg"
    alt="description here" /> <br /> EUMETSAT SEVIRI
    spectral channel IR 10.8 (copyright 2018 EUMETSAT) </td> </tr> </center>
{% endhighlight %}

<center> <td align="center" valign="center"> <img
SRC="https://eumetview.eumetsat.int/static-images/latestImages/EUMETSAT_MSG_IR108Color_SouthernAfrica.jpg"
alt="description here" alt="description here" /> <br /> EUMETSAT SEVIRI
spectral channel IR 10.8 (copyright 2018 EUMETSAT).  </td> </center>

### Array in bash

To work with arrays in bash you must call the array variable 
"${array[@]}"

{% highlight bash %}
array=(12 18 24 30 36 42 48)

for count in "${array[@]}" 
do 
    echo $i 
done
{% endhighlight %}

### Making barcodes
Making barcodes in Linux is very easy, install barcode, run the command convert the ps file to pdf using ps2pdf

{% highlight bash %}
sudo apt install barcode
barcode -t 3x6 -i Oatmeal 128 -o output.ps
ps2pdf output.ps oatmealbarcode.pdf
{% endhighlight %}
