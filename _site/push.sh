#!/bin/bash
echo "Press crtl-c when prompt "

bundle exec jekyll serve
git add .

echo -n "What do you want to name your commit? [ENTER]: "
read name

git commit -m "$name"
git push origin master
