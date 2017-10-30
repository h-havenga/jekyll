---
layout: page
title: GNU\Linux
permalink: /linux/
---

I currently run Debian *Testing* with the Gnome 3 environment. VIM is my
text editor of choice while I use Terminator as my default terminal.

### Useful command line tools
gmt | youtube-dl | gdal | photorec | imagemagic |
gnuplot | ncview | nco | cdo | pdftk | ranger

______
### Useful one liners

Convert a bunch of GoPro images for a time-laps 
{% highlight bash %}
ffmpeg -r 30 -y -pattern_type glob -i '*.JPG' -vf "crop=h=2250" -c:v libx264 -crf 20 -s 1280x720 output.avi'
{% endhighlight %}

Convert a 16bit tiff thermal image to something more viewable
{% highlight bash %}
gdal_translate in_file.tiff out_file.tiff -b 1 -scale 6880 7641 0 65535
{% endhighlight %}

Convert a Panasonic Raw (from MAPIR Survey2 Camera) to a usable jpg and transfer exif
info from the correpsonding JPG (weird setup, I know)
{% highlight bash %}
darktable-cli in_file.RAW out_file.jpg && exiftool -tagsfromfile in_file.JPG -x Orientation out_file.jpg
{% endhighlight %}

Split Netcdf files by level
{% highlight bash %}
cdo splitlevel,500 infile_with_various_levels.nc outfile_with_level_500.nc
{% endhighlight %}

Remove a page in a PDF file (remove first page of a 7 page pdf file)
{% highlight bash %}
pdftk infile.pdf cat 2-7 output outfile.pdf
{% endhighlight %}
