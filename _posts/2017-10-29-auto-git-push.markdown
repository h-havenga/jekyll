---
layout: post
title:  "Automatically push my updated site to Github"
date:   2017-10-29 14:43:28 +0200
categories: linux github
---

This is a very simple script I made that allows me to edit my website
locally, build it locally and as soon as I am satisfied I can push it to my
Github account. After this is completed it takes a couple of minutes for
the site to be updated. For it to work you have to have a Github account
and also go through the whole process of pulling and pushing, detailed
[here](https://help.github.com/articles/github-flow/).
 

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
