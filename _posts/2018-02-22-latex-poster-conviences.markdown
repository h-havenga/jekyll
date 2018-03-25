---
layout: post
title:  "Making a poster with LaTex"
date:   2018-02-22 12:43:29 +0200
categories: latex poster 
---

LaTex is one of those cool things that suck you into the metaphorical rabbit
hole. I hesitantly started writing my thesis in it somewhere in 2016 mostly out
of my own initiative, my supervisor was using it but he recommended everyone
against it and I would do the same, it's just not that efficient and you can't
hide behind Microsoft Office's fancy spelling/grammar checks and it lacks some
support, our University's writing department did not even know what LaTex is,
this might be the case at other institutions to.

Making a poster in LaTeX was an surprisingly enjoyable exercise. After finding
the the right combination of packages and experimenting with the layout the
setup below best suited me. I'll start off with the packages in the preamble.

{% highlight latex %}
\documentclass[a1,final]{a0poster}
\usepackage{graphicx}
\usepackage[absolute,overlay]{textpos}
\usepackage[colorgrid,texcoord]{eso-pic}
\setlength{\TPHorizModule}{1cm}
\setlength{\TPVertModule}{1cm}
{% endhighlight %}

[*documentclass{a0poster}*](www.ctan.org/pkg/a0poster) conveniently sorts out
the formatting problems related to the poster size, things like fonts and
formulas. The [*textpos*](www.ctan.org/pkg/textpos) allows you to specify the
exact position of text boxes, or figures, in the posters as an x,y point and we
can see this x,y grid by using the [*eso-pic*](www.ctan.org/pkg/eso-pic) package.
The textpos documentation tells us that both _TPHoriz_ and _TPVert_ refer to
the x,y size parameters of the of the text block environment. You can also
change the layout to portrait (default is landscape) by doing
*/documentclass[portrait,a0,final]* and change the aX to 0 or 1 depending on
your desired size

Try this out to get a feel:
{% highlight latex %}
% The preamble 
\documentclass[a1,final]{a0poster}
\usepackage{graphicx}
\usepackage[absolute,overlay]{textpos}
\usepackage[colorgrid,texcoord]{eso-pic}
\setlength{\TPHorizModule}{10mm}
\setlength{\TPVertModule}{10mm}

% Begin
\begin{document}

% Title
\begin{textblock}{26}(2, 2)
\VeryHuge Poster Making 101
\end{textblock}

\end{document}
{% endhighlight %}

You should get this output:
![basic_poster]({{ "/assets/images/random/poster_basic.png" | absolute_url }})

Adding and positioning blocks of text is pretty easy. I'm going to use the
*\lipsum* package to avoid writing my own stuff :).

{% highlight latex %}
% The preamble 
\documentclass[a1,final]{a0poster}
\usepackage{graphicx}
\usepackage[absolute,overlay]{textpos}
\usepackage[colorgrid,texcoord]{eso-pic}
\setlength{\TPHorizModule}{10mm}
\setlength{\TPVertModule}{10mm}
\usepackage{lipsum}

% Begin
\begin{document}

% Title
\begin{textblock}{26}(2, 2)
\VeryHuge Poster Making 101 
\end{textblock}

% Text Box 1
\begin{textblock}{50}(2, 6)
\large \lipsum[60] 
\end{textblock}

% Text Box 2
\begin{textblock}{30}(53, 6)
\large \lipsum[80] 
\end{textblock}

% Text Box 3
\begin{textblock}{15}(68, 27)
\large \lipsum[40] 
\end{textblock}

% A Fancy Picture made with GMT of course
\begin{textblock}{0}(0, 10)
\begin{figure}
\includegraphics{hail_composite_globe.pdf}
\end{figure}
\end{textblock}

\end{document}
{% endhighlight %}

And then you a very nice layout a1, landscape poster.

![basic_final]({{ "/assets/images/random/poster_not_so_basic.png" | absolute_url }})

To remove the grids, uncomment \usepackage[colorgrid,texcoord]{eso-pic} and to
remove the boxes around the text (altough it might be good to keep them) remove
*showboxes* in the *eso-pic* package.


![basic_final]({{ "/assets/images/random/poster_no_grid.png" | absolute_url }})

