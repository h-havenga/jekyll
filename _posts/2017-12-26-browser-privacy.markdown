---
layout: post
title:  "Browsing: attempting to balance useablity with privacy" 
date:   2017-12-26 12:43:29 +0200
categories: firefox security
---

I am of the opinion that most of what we do on a computer occurs in our browser
these days, anything from banking, shopping, connecting, reading and learning
all occurs within this one box. 

#### My browser

[Firefox](https://www.mozilla.org/en-US/firefox/) is my daily browser. I like
their open-source commitment and I've never had any major issues, I'm sure I'll
switch without any guilt if that changes. I'm also a big fan of Firefox Focus
for mobile browsing. A browser that has caught my attention is
[Qutebrowser](https://qutebrowser.org/), its characteristic feature is the vim
like key-bindings, maybe in the future I'll use it a little more.

#### My add-ons
Attempting to balance privacy with usability is hard, websites break without
much effort if you use tracking and add blocking tools or the wrong combination
of them. However I have found the following to not ruin my experience at all.
I have three main add-ons that I advocate everyone to use without thinking about
it:

+ [uBlock Origin](https://github.com/gorhill/uBlock/)
    + Block annoying ads and can prevent WebRTC leak IP leak without going into 
    *about:config*
+ [HTTPS Everywhere](https://www.eff.org/https-everywhere)
    + Make sure you connect to a site using the encrypted https protocol
+ [Privacy Badger](https://www.eff.org/privacybadger)
    + Detect and prevent tracking

Some more obscure add-ons I've added, which may be overkill, include:
+ [Decentraleyes](https://decentraleyes.org/)
+ [Popup Blocker](https://add0n.com/popup-blocker.html)
+ [CanvasBlocker](https://github.com/kkapsner/CanvasBlocker/) 

Along with this you my I set my browser to never remember passwords or autofill
forms (I use a password manager for this), to only accept cookies from sites
I visited, Tracking Prevention and Do Not Track Request is on. Firefox can
further be customized by entering the *about:config*, I recommend reading
trough [Privacy Tools](https://www.privacytools.io/#) before configuring
settings here, some settings make the browsing experience a little less
convenient or break websites.

Of course you can use [TOR](https://www.torproject.org/) if you're really
paranoid, but from my experience simple things start getting annoying if you
reach this level.
