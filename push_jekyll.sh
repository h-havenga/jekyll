#!/bin/bash
echo "This is a automated git push script for Jekyll, use it at your own risk "

timeout 15 bundle exec jekyll serve

git add .

echo -n "What do you want to name your commit? [ENTER]: "
read name

git commit -m "$name"
git push origin master

echo "Push Successful!"
