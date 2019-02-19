---
layout: post
title:  "Working with an excel multisheet spreadsheet in R"
date:   2019-02-17 09:40:29 +0200
categories: R  
---

{% highlight R %}
library(rio)
exceldf <- import_list("filewithatonoftabs.xlsx")
{% endhighlight %}

There is 76 tabs in this sheet -- F*ck.

Write a for loop in bash

{% highlight bash %}
for i in {1..76}; do echo "\"d\$Sheet$i\"," ; done
{% endhighlight %}

And paste the result in rbindlist to create a workable df.
Ps. I only did this becuase my R loop was not working

{% highlight R %}
df <- rbindlist(list(df$Sheet1, df$Sheet2, df$Sheet3, df$Sheet4, df$Sheet5, df$Sheet6,
df$Sheet7, df$Sheet8, df$Sheet9, df$Sheet10, df$Sheet11, df$Sheet12,
df$Sheet13, df$Sheet14, df$Sheet15, df$Sheet16, df$Sheet17, df$Sheet18,
df$Sheet19, df$Sheet20, df$Sheet21, df$Sheet22, df$Sheet23, df$Sheet24,
df$Sheet25, df$Sheet26, df$Sheet27, df$Sheet28, df$Sheet29, df$Sheet30,
df$Sheet31, df$Sheet32, df$Sheet33, df$Sheet34, df$Sheet35, df$Sheet36,
df$Sheet37, df$Sheet38, df$Sheet39, df$Sheet40, df$Sheet41, df$Sheet42,
df$Sheet43, df$Sheet44, df$Sheet45, df$Sheet46, df$Sheet47, df$Sheet48,
df$Sheet49, df$Sheet50, df$Sheet51, df$Sheet52, df$Sheet53, df$Sheet54,
df$Sheet55, df$Sheet56, df$Sheet57, df$Sheet58, df$Sheet59, df$Sheet60,
df$Sheet61, df$Sheet62, df$Sheet63, df$Sheet64, df$Sheet65, df$Sheet66,
df$Sheet67, df$Sheet68, df$Sheet69, df$Sheet70, df$Sheet71, df$Sheet72,
df$Sheet73, df$Sheet74, df$Sheet75, df$Sheet76))[order(ClimNo)]

# Save the csv so you wont have to repeat this
write.csv(df_2, file = "./yourfile.csv", row.names = TRUE)
{% endhighlight %}

