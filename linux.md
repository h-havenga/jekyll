---
layout: page
title: GNU\Linux
permalink: /linux/
---

In 2013 I started using Ubuntu to run The Weather Research and Forecasting
Model (WRF) for my final year project. Although I wasn’t to keen I found it
really cool. The command line was mythical for me back then. It wasn’t
until 2016 that I finally decided to get rid of Windows and just run
GNU\Linux. Initially I started with Ubuntu LTS and soon I stumbled on
Ubuntu Gnome and I really loved the environment. I _distro hopped_ for a
while, I probably reinstalled my system every week for about two months. I
installed Debian somewhere there and after changing it to testing I was
hooked. The system was more stable than any release I ever had. Currently
have computers running Debian testing, a Dell E6220 with Gnome 3 and a
small Acer Netbook with Mate I use when I travel. Both systems have not let
me down and despite the testing tag both have been very stable.  

![linux]({{ "/assets/images/random/linux.png" | absolute_url }})

### Command Line Tools
Generic Mapping Tools (GMT) | youtube-dl | gdal | 

______
### Useful scripts and stuff

Compile Jekyll site locally and push to site repository
{% highlight bash %}
#!/bin/bash
echo "This is a automated git push script for Jekyll, use it at your own risk "

timeout 15 bundle exec jekyll serve

git add .

echo -n "What do you want to name your commit? [ENTER]: "
read name

git commit -m "$name"
git push origin master

echo "Commit Successful!"
{% endhighlight %}
