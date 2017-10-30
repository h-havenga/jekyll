---
layout: post
title:  "Hacking my jekyll theme"
date:   2017-11-01 12:43:29 +0200
categories: jekyll hacks
---

One of my main goals with this site is to the keep it simple while also
tweaking it to my liking. The default Jekyll theme is Minima, a bare to
bones theme with a basic layout. This allowed me to easily figure out the
Jekyll site structure which made editing *easy*. Be aware that I
am no web-developer, html or markdown expert. This site is heavily hacked,
with bad code in some cases. It works nevertheless.

The first major change was the landing page. The default was just an index
posts. Not to interesting if you're a new visitor I reckoned. So to
change the landing page I had to edit the *_layouts/home.html* folder.  I
completely removed all content. My idea was to write something informal
with some pictures. I initially did it all in one top to bottom frame. It
was however to much. I then thought about columns or something similar. I
did,

{% highlight html %}  
<div class="home">
  <h1 class="page-heading" align="center">Heading</h1>

<html>
<head>
  <title>Cols</title>
  <style>
    #left {
      width: 360px;
      float: left;	
    }
    #right {
      margin-left: 370px;
    }
    .clear {
      clear: both;
    }
  </style>
</head>

<body>
  <div id="container">
   <div id="left">
   </div>
   <p> bla bla bla </p>
   <div id="right">
   <img src="image/source" vspace="1">
   <img src="image/source" vspace="1">
   </div>
  </div>
</body> 

</html>
</div>
{% endhighlight %}

Perfect. The *vspace* allowed for a kind of border between the images,
otherwise there is no separation.  

***Headers***  

I wanted some custom header links and remove the *about* link (more one
that one later). Creating one was easy, in the home folder I just added a
.md file for all the new links, e.g.

{% highlight markdown %}
---
layout: page
title: Running
permalink: /running/
---
{% endhighlight %}

***Content***  
Because I've never worked with all this before I had to figure some things
out on the fly. To create some random headers I just did [### heading],
with each # indicating a level of header. What I also figured out is that
there needs to be an extra space after the last word to create a newline. 

To get the Strava widgets to fit horizontally and be equal in size
vertically you need to edit the widget width and height, changing this to
365 allowed the frame to fit in the page, however, on a mobile phone the
widgets are arranged vertically instead of horizontally.  

***Footer***  
The footer required some major editing. The title of the page is displayed
twice, with the inclusion of my name for social media it would have meant
my name was displayed 6 times per page. No way. To remove the site title
from the footer you have to go to *_includes/footer*, I removed everything
that had the word title in it. Next was to remove my name from the social
media badges, create new icons for mail and rss and just add a generic name
instead of my username. Twitter and Github already had icons, with a
corresponding *icon-mail.html* file. After a 60 second search I had a
icon for email and rss, great. I resized them with image magic to
16x16,

{% highlight bash %}
convert icon-rss.png -resize 16x16 icon-rss.svg
{% endhighlight %}

The site now feels more like me, while keeping the simplicity of minima.
All these hacks can be viewed on my Github site. 

______


Check out the [Jekyll docs][jekyll-docs] for more info on how to get the
most out of Jekyll. File all bugs/feature requests at [Jekyll’s GitHub
repo][jekyll-gh]. If you have questions, you can ask them on [Jekyll
Talk][jekyll-talk].

[jekyll-docs]: https://jekyllrb.com/docs/home [jekyll-gh]:
https://github.com/jekyll/jekyll [jekyll-talk]: https://talk.jekyllrb.com/
