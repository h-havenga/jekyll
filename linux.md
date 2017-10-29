---
layout: page
title: GNU\Linux
permalink: /linux/
---

I currently have two computers running Debian testing, a Dell E6220 with
Gnome 3 and a small Acer Netbook with Mate I use when I travel. Despite the
testing tag both systems have been very stable.  

![linux]({{ "/assets/images/random/debian_logo.png" | absolute_url }})

### Useful command line tools
Generic Mapping Tools (GMT) | youtube-dl | gdal | 

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


