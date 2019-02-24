---
layout: post
title:  "Shapefiles in R - extracting data in a spesific polygon"
date:   2019-02-24 09:40:29 +0200
categories: R  
---

I encountered an issue where I wanted to extract points located within
a specific shapefile, in this case the Highveld ecoregion and Gauteng.
Instead of extracting the points in R I assign them a 1/0 (TRUE/FALSE) value in
a new column using *point.in.polygon*, following this I the *filter* function
in R to create a new dataframe where Highveld == 1. In theory you could use the
*over* function which is part of the rgdal package, but I found this
cumbersome.

So here we have a nice example dataset that is geo-referenced, lets call it _libsum.csv_
{% highlight csv %}
Date     ;Event         ;Place                    ;Latitude  ;Longitude  ;Height(m)               
2014/2/3 ;Rain/flooding ;JOHANNESBURG, GAUTENG    ;-26.12    ;28.02      ;1749       		
2014/2/3 ;Rain/flooding ;SOWETO, GAUTENG          ;-26.14    ;26.15      ;1646       		
2014/2/3 ;Rain/flooding ;LENASIA, GAUTENG         ;-26.20    ;27.51      ;1574       		
2014/2/3 ;Rain/flooding ;TEMBISA, GAUTENG         ;-26.00    ;28.12      ;16         		
2014/2/3 ;Rain/flooding ;MIDRAND, GAUTENG         ;-25.56    ;28.08      ;1539       		
2014/2/3 ;Rain/flooding ;CENTURION, GAUTENG       ;-25.51    ;28.11      ;1432       		
2014/2/3 ;Rain/flooding ;RANDBURG, GAUTENG        ;-26.08    ;27.59      ;1603       		
2014/2/3 ;Rain/flooding ;ROODEPOORT, GAUTENG      ;-26.07    ;27.54      ;1747       		
2014/2/3 ;Rain/flooding ;ALEXANDRA, GAUTENG       ;-26.06    ;28.05      ;1546       		
2014/2/3 ;Rain/flooding ;KRUGERSDORP, GAUTENG     ;-26.07    ;27.54      ;1727       		
2014/2/3 ;Rain/flooding ;MAKHADO, LIMPOPO         ;-23.02    ;29.54      ;950        		
2014/2/3 ;Rain/flooding ;THOHOYANDOU, LIMPOPO     ;-22.52    ;30.28      ;741        		
2014/2/3 ;Rain/flooding ;DELAREYVILLE, NORTH-WEST ;-26.41    ;25.27      ;1349       		
2014/2/3 ;Rain/flooding ;OTTOSDAL, NORTH-WEST     ;-26.48    ;26.00      ;1504       		
2014/2/3 ;Rain/flooding ;VRYBURG, NORTH-WEST      ;-26.57    ;24.43      ;1199       		
2014/2/3 ;Rain/flooding ;WOLMARANSTAD, NORTH-WEST ;-27.12    ;25.58      ;1356       		
2014/2/3 ;Rain/flooding ;TSWAING, NORTH-WEST      ;-26.39    ;25.46      ;1405       		
2010/2/3 ;Other         ;MAGALIESBERG             ;-26.00    ;27.55      ;1480       		
2014/2/3 ;Other         ;LANSERIA, GAUTENG        ;-25.26    ;27.55      ;1362       		
{% endhighlight %}

Now we can open R

{% highlight R %}
# Load some usefull libraries
library(tidyverse)
library(ggplot2)
library(reshape2)
library(viridis)
library(rgdal)
library(grid)
library(readr)
library(gridExtra)
library(raster)
library(GSODR)
library(rgeos)
# sudo apt install libgeos\* 
library(sp)
theme_set(theme_classic(base_size=22))

# Lets load the df first
df <- read.csv("libsum.csv", sep=";", header=TRUE)

#To actually work with the shapefiles, omit the map_data function
# and invoke it later
basemap_1  <- readOGR(dsn="./", layer="ZAF_adm1")
ecoregions <- readOGR(dsn="./", layer="Ecoregions2017")

# To extract a layer to use in a plot, in this case Gauteng and the Highveld,
# do:
gauteng  <- map_data(basemap_1[basemap_1$NAME_1=="Gauteng", ])
highveld <- map_data(ecoregions[ecoregions$ECO_ID=="81", ])

# Here we extract data that falls within the Higheld ecoregion and Gauteng
# We create a new column in the df where a 1 or 0 will be assigned if it falls inside the
# lat and lon of the corresponding polygon
df$Highveld <- point.in.polygon(df$Longitude, df$Latitude, highveld$long, highveld$lat)
df$Highveld <- as.character(df$Highveld)

# And we do the same for Gauteng
df$Gauteng <- point.in.polygon(df$Longitude, df$Latitude, gauteng$long, gauteng$lat)
df$Gauteng <- as.character(df$Gauteng)
{% endhighlight %}

After running this the df should look something like this
{% highlight csv %}
Date     ;Event;Place                             ;Latitude;Longitude;Height (m); Highveld;Gauteng
2014/2/3 ;Rain/flooding ;JOHANNESBURG; GAUTENG    ;-26.12; 28.02;    1749;        1;       1
2014/2/3 ;Rain/flooding ;SOWETO; GAUTENG          ;-26.14; 26.15;    1646;        1;       0
2014/2/3 ;Rain/flooding ;LENASIA; GAUTENG         ;-26.2;  27.51;    1574;        1;       1
2014/2/3 ;Rain/flooding ;TEMBISA; GAUTENG         ;-26;    28.12;    16  ;        1;       1
2014/2/3 ;Rain/flooding ;MIDRAND; GAUTENG         ;-25.56; 28.08;    1539;        0;       1
2014/2/3 ;Rain/flooding ;CENTURION; GAUTENG       ;-25.51; 28.11;    1432;        0;       1
2014/2/3 ;Rain/flooding ;RANDBURG; GAUTENG        ;-26.08; 27.59;    1603;        1;       1
2014/2/3 ;Rain/flooding ;ROODEPOORT; GAUTENG      ;-26.07; 27.54;    1747;        1;       1
2014/2/3 ;Rain/flooding ;ALEXANDRA; GAUTENG       ;-26.06; 28.05;    1546;        1;       1
2014/2/3 ;Rain/flooding ;KRUGERSDORP; GAUTENG     ;-26.07; 27.54;    1727;        1;       1
2014/2/3 ;Rain/flooding ;MAKHADO; LIMPOPO         ;-23.02; 29.54;    950 ;        0;       0
2014/2/3 ;Rain/flooding ;THOHOYANDOU; LIMPOPO     ;-22.52; 30.28;    741 ;        0;       0
2014/2/3 ;Rain/flooding ;DELAREYVILLE; NORTH-WEST ;-26.41; 25.27;    1349;        0;       0
2014/2/3 ;Rain/flooding ;OTTOSDAL; NORTH-WEST     ;-26.48; 26;       1504;        1;       0
2014/2/3 ;Rain/flooding ;VRYBURG; NORTH-WEST      ;-26.57; 24.43;    1199;        0;       0
2014/2/3 ;Rain/flooding ;WOLMARANSTAD; NORTH-WEST ;-27.12; 25.58;    1356;        1;       0
2014/2/3 ;Rain/flooding ;TSWAING; NORTH-WEST      ;-26.39; 25.46;    1405;        1;       0
2010/2/3 ;Other         ;MAGALIESBERG             ;-26   ; 27. 55;   1480;        0;       1
2014/2/3 ;Other         ;LANSERIA; GAUTENG        ;-25.26; 27.55;    1362;        0;       0
{% endhighlight %}

Now we can create a new dataframe to work with that only contains the data that
falls within the polygons of interest

{% highlight R %}
df_hv <- df %>% filter(Highveld == 1)
df_gp <- df %>% filter(Gauteng == 1)
{% endhighlight %}
