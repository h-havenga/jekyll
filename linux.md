---
layout: page
title: GNU\Linux
permalink: /linux/
---

I currently run Debian *Testing* and I use VIM. None of this matters
of course, I just think it's cool. 

### Useful command line tools
gmt | youtube-dl | gdal | photorec | imagemagic |
gnuplot | ffmpeg | ncview | nco | cdo | pdftk | ranger

______
### Useful one liners

Convert a bunch of GoPro images for a time-laps 
{% highlight bash %}
ffmpeg -r 30 -y -pattern_type glob -i '*.JPG' -vf "crop=h=2250" -c:v libx264 -crf 20 -s 1280x720 outfile.avi'
{% endhighlight %}

Screencasting with ffmpeg
{% highlight bash %}
ffmpeg -f x11grab -s 1366x768 -i :0.0 -c:v libx264 -qp 0 out.mkv 
{% endhighlight %}

Convert a 16bit tiff thermal image to something more viewable
{% highlight bash %}
gdal_translate infile.tiff outfile.tiff -b 1 -scale 6880 7641 0 65535
{% endhighlight %}

Convert a Panasonic Raw (from MAPIR Survey2 Camera) to a usable jpg and transfer exif
info from the correpsonding JPG (weird setup, I know)
{% highlight bash %}
darktable-cli infile.RAW outfile.jpg && exiftool -tagsfromfile infile.JPG -x Orientation outfile.jpg
{% endhighlight %}

Split Netcdf files by level
{% highlight bash %}
cdo splitlevel,500 infile_with_various_levels.nc outfile_with_level_500.nc
{% endhighlight %}

Remove a page in a PDF file (remove first page of a 7 page pdf file)
{% highlight bash %}
pdftk infile.pdf cat 2-7 output outfile.pdf
{% endhighlight %}

Compress a pdf file 
{% highlight bash %}
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dBATCH -sOutputFile=outfile.pdf infile.pdf
{% endhighlight %}

LaTeX needs to be compiled twice, instead of running commands over and
over do:
{% highlight bash %}
for i in `seq 2`; do makeglossaries texfile && bibtex texfile && lualatex texfile.tex ; done
{% endhighlight %}

To make LaTex compiling even more simple, use zsh and do:
{% highlight zsh %}
repeat 2 { makeglossaries texfile && bibtex texfile && lualatex texfile.tex }
{% endhighlight %}

Update all git repositories in a given directory
{% highlight zsh %}
for i in */.git; do ( echo $i; cd $i/..; git pull; ); done
{% endhighlight %}
