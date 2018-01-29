---
layout: page
title: Writings
permalink: /writings/
---

<center> Assume TL;DR for some posts </center>

<ul>
{% for post in site.posts %}
  {% assign currentdate = post.date | date: "%B %Y" %}
  {% if currentdate != date %}
    {% unless forloop.first %}</ul>{% endunless %}
    <h1 id="y{{post.date | date: "%Y"}}">{{ currentdate }}</h1>
    <ul>
    {% assign date = currentdate %}
  {% endif %}
     <li>
     <span>{{ post.date | date:"%-d %b %Y" }} > </span>      
	 <a href="{{ post.url }}">{{ post.title }}</a>
     </li>
  {% if forloop.last %}</ul>{% endif %}
{% endfor %}
</ul>
