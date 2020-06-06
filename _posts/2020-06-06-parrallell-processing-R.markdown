---
layout: post
title:  "R - Using your computer's resources more effectively"
date:   2020-06-06 09:40:29 +0200
categories: R  
---

The difficulties of maintaining a blog have come to light. This is my first,
and maybe only, post for 2020. I had high hopes initially for this to thrive,
but alas, life happens... But here is my little note for 2020, a small snippet
of code to speed up your slow R analysis.


{% highlight R %}
library(parallel)
library(MASS)
library(foreach)
library(doParallel)

# Choose how to utilize resources.
# Do not use all your computing power for this. Your system will freeze!
# detectCores tells you how much power you have.
# - 2 says, "Hey China, leave 2 cores out of this"

numCores <- detectCores() - 2
numCores
registerDoParallel(numCores)

# A simple plotting example that uses more than one processor
# to mindlessly plot over 70 variables. Not a good strategy
colnames <- c(names(df)[10:62], names(df)[71:76]) 
plot_list = list()

for (i in colnames)
{
    plt <- ggplot(df, aes_string(x="Month", y=i, group="Month", color="MeanDbz.dBZ.")) +
    geom_jitter(alpha=0.2) +
    stat_boxplot(geom ='errorbar') + geom_boxplot() +
    ggtitle(paste("Brazil -", i)) + ylab(paste(i)) + xlab("Month") +
    xlim("1","2","3","4","5","6","7","8","9","10","11","12") +
    scale_fill_viridis_c() +
    labs(fill="Mean DbZ") + guides(color=FALSE)
    plot_list[[i]] = plt
}

foreach(i = colnames) %dopar% {
    file_name = paste("Brazil_Month", i, ".png", sep="")
    png(file_name, width = 8 * 500, height = 4 * 500, res = 300)
    print(plot_list[[i]])
    dev.off()
}

stopImplicitCluster()
{% endhighlight %}


