---
layout: post
title:  "Setting a random mac address for a specific network"
date:   2017-11-20 14:43:28 +0200
categories: linux network bash
---

A network card has a mac address assigned to it by which a network can
identify you. It is a widely used way to restrict or
monitor your access on a and it could be useful in such cases
to have a randomly assigned mac address to improve your privacy and
anonymity. The script is just a bunch a of commands, you can run them
separately if you want to, this just makes it easier to reuse instead
of remembering every step. The mac address should change with every
reconnect. 

{% highlight bash %}
#!/bin/bash
read -p "This script changes your WiFi mac address. Use this at your
own risk and obey all local laws. By pressing enter you agree that you
understand the risks you may face! Press ctrl-c to exit otherwise "

echo "Listing all connections. Connected devices are highlighted"
nmcli con show 

read -p "Enter the name of the network you wish to modify exactly as
seen above and press enter " name 
nmcli con modify "$name" wifi.cloned-mac-address random

echo "Check that the cloned mac address is set to random" 
nmcli con show "$name" | grep "cloned-mac-address"

read -p "Your mac address has been changed and will randomly reassign
each time you restart your connection. Press enter to exit "
{% endhighlight %}

To use this script save it as something, like
machange.sh and then do;

{% highlight bash %}
bash machange.sh
{% endhighlight %}

