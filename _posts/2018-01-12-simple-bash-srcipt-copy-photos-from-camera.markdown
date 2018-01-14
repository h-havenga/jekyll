---
layout: post
title:  "Automating some tasks with bash: coping photos from camera"
date:   2018-01-14 12:43:29 +0200
categories: bash automatization 
---

I recently downloaded Ubuntu on a new pc for my family, in my quest to convince
them of the *usefulness* of Linux, I wrote a little script for them to use when
downloading photos from their cameras instead of going through the tedious
process of clicking a mouse 25 times. If my attempts to actually get them into
the Linux system works is another question.

{% highlight bash %}
#!/bin/bash
#Author: Henno Havenga
#This is a quick and dirty Canon EOS download script from the SD card reader

#Name of file = download date
date=$(date +%Y_%m_%d)

cowsay -f gnu "Welcome"

read -p "Photos will be saved under Pictures/$date/70D. Press ENTER to continue "

#Make directory
mkdir -p ~/Pictures/$date/70D

#Copy photos to new directory, when done open directory
cp --verbose /media/ubuntu/EOS_DIGITAL/DCIM/100CANON/* ~/Pictures/$date/70D

cowsay -f gnu "All Done"

read -p "Photos saved to /Pictures/$date/70D. Press ENTER to open the folder "

nautilus ~/Pictures/$date/70D &&

exit 0
{% endhighlight %}

To make the file an desktop shortcut was actually more effort then I thought.
You have to create the following in the Desktop directory under something like
Canon_Downloads.desktop and add the following to its contents

[Desktop Entry]   
Name=70D_Photo_Download  
Comment=Download RWFL photos from Canon 70D   
Exec=bash -c '~/Programs/bash_scripts/GetPhotos70D.sh'  
Icon=utilities-terminal  
Terminal=true  
Type=Application  
Categories=Application  
Name=70D_Photo_Download  

The last think is to make sure both the bash and the .desktop is executable. To
make a executable just do

{% highlight bash %}
chmod +x inputfile
{% endhighlight %}

And now it's just a double click away
