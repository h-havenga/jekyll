---
layout: post
title:  "Part 1: Basic Mapping with GMT"
date:   2017-10-19 10:00:29 +0200
categories: maps data
---

Generic Mapping Tools (GMT) is a relatively unknown command line tool for geo and
spatial analysis. I say unknown because I only know one other person who
actually uses it. Looking for resources online does however indicate that
some universities have courses teaching GMT, no such luck for me, I had to
learn it myself. I'd say the learning curve is quite steep, the only tool I
can compare it with right now is GNUPLOT, another really cool command line
tool for creating high quality graphics. 

To create your map is pretty easy, if you use a bash script it is even
easier in my humble opinion. Let's start off with a map of South-Africa
directly from the command line:

First install gmt:
{% highlight bash %}
sudo apt install gmt
{% endhighlight%}

Now we can make a basic map directly from the command line:

{% highlight bash %}
gmt pscoast -R15/34/-35/-22 -JM20 -Ba -B+t"South-Africa" -Na -W -Df -G100/200/100 -S0/50/250 > south_africa.ps
{% endhighlight%}

Breaking the commands down make the syntax a little more understandable in
bash. Feel free to use whatever editor you like. Lets do: 

{% highlight bash %}
$ vim southafrica.sh
{% endhighlight%}

in your new .sh script

{% highlight bash %}
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

# Lets make a base map by calling GMT  
gmt psbasemap -R$west/$east/$south/$north $proj $tick -X5 -K > $out

# Lets start drawing some boundaries
# N = National Borders (Na = National Borders All)
gmt pscoast -R -J -O -K -W0.25 -Df -B+t"South Africa" -Na -W0.05 -G$g_red/$g_green/$g_blue -S$s_red/$s_green/$s_blue >> $out 
{% endhighlight%}

You should see this basic map of South-Africa:  
![gmtmap]({{ "/assets/images/maps/south_africa.png" | absolute_url }})

<sub>Note that I converted is from postscript format to reduce size. </sub>  

This breaks down the commands and when you need to you can just edit the
script as you need to. Obviously this is the most basic of maps. I'll try
and get some more advanced maps as this blog evolves. 
