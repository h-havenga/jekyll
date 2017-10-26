#!/bin/bash
bundle exec jekyll serve
git add .
git commit -m "first commit"
git push origin master
