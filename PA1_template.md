# Reproducible Research: Peer Assessment 1
Gene Kaufman, based on template cloned from [http://github.com/rdpeng/RepData_PeerAssessment1](http://github.com/rdpeng/RepData_PeerAssessment1)  
## Loading and preprocessing the data
First, we're going to set some global options (as shown in video notes)

```r
require(knitr)
opts_chunk$set(echo=TRUE, results="asis", warning=FALSE, message=FALSE)
library(dplyr)

# replace default knitr inline formatter to more nicely display numbers that
# don't need to use scientific notation
# inline_hook solution credit: Jason French and Winston Chang
#  http://www.jason-french.com/blog/2014/04/25/formatting-sweave-and-knitr-output-for-2-digits/
inline_hook <- function(x){
  if(is.numeric(x)){
    res <- ifelse(x == round(x),
        sprintf("%d",x),
        sprintf("%.4f",x)
    )
    paste(res,collapse=", ")
  } else { # anything non-numeric just passes through
    x
  }
}
knit_hooks$set(inline=inline_hook)
```

Download data file, if necessary. Unzip and save to local computer

```r
zip_file_url <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip"
zip_file_local <- "repdata_data_activity.zip"
data_file <- "activity.csv"
if (!file.exists(zip_file_local)) {
  download.file(zip_file_url,destfile = zip_file_local,mode="wb")
}
if (!file.exists(zip_file_local)) {
  stop("Failed to retrieve zip file!")
}
unzip(zip_file_local)
```

Read data

```r
data_raw <- read.csv(data_file)
unlink(data_file)	# we don't need to keep the unzipped file around any longer
```


Create a data frame without NA's (nona), grouped by day

```r
data_nona_by_day <- data_raw %>%
  filter(!is.na(steps)) %>%
  group_by(date)  %>%
  summarize(daily_steps_total=sum(steps))
```

*Make a histogram of the total number of steps taken each day*

```r
with(data_nona_by_day,
     hist(daily_steps_total,
          main="Histogram - NA's ignored",
          xlab="Total Daily Steps",
          col="blue"))
```

![](PA1_template_files/figure-html/data_nona_by_day_hist-1.png) 

## What is mean total number of steps taken per day?


```r
daily_nona_steps_mean <- mean(data_nona_by_day$daily_steps_total)
daily_nona_steps_median <- median(data_nona_by_day$daily_steps_total)
```

Ignoring NAs, the mean total number of steps taken per day is **10766.1887** (rounded to 4 decimal places), with a median of **10765** steps.

          
## What is the average daily activity pattern?

Create a data frame without NA's (nona), grouped by interval

```r
data_nona_by_interval <- data_raw %>%
  filter(!is.na(steps)) %>%
  group_by(interval)  %>%
  summarize(interval_steps_mean = mean(steps),
            interval_steps_total = sum(steps))
```

*Make a time series plot (i.e. type = "l") of the 5-minute interval (x-axis) and the average number of steps taken, averaged across all days (y-axis)*

```r
with(data_nona_by_interval,
     plot(interval,interval_steps_mean, 
     type = "l",
     main="Average steps/interval",
     xlab="Interval",
     ylab="Average steps"))
```

![](PA1_template_files/figure-html/data_nona_by_interval_tsplot-1.png) 

*Which 5-minute interval, on average across all the days in the dataset, contains the maximum number of steps?*

```r
intervals_list <- unique(data_raw$interval)	# list of intervals

max_interval_steps <- intervals_list[which.max(data_nona_by_interval$interval_steps_total)]
```
The interval with the highest average across all days is **835**.

## Imputing missing values

A list of NAs will be useful

```r
na_steps_ndx <- is.na(data_raw$steps)		# index of NAs
```

1. *Calculate and report the total number of missing values in the dataset (i.e. the total number of rows with NAs)*

```r
# na_steps_ndx is a logical vector indicating which rows had NAs. 
# Running a sum on that will indicate the number of NAs
num_nas <- sum(na_steps_ndx)
```

The number of missing values is **2304**.

2. *Devise a strategy for filling in all of the missing values in the dataset.*

Strategy: replace NA steps with median for that interval

3. *Create a new dataset that is equal to the original dataset but with the missing data filled in*

```r
#initialize new data frame (data_new) with raw data
data_new<-data_raw

# replace steps with missing values with the mean for that interval. Matching 
# the interval for a missing step to the intervals_list provides the correct 
# index to the summary dataframe (data_nona_by_interval), and from there we 
# return the mean for that interval
data_new[na_steps_ndx,]$steps <- data_nona_by_interval[match(data_new[na_steps_ndx,]$interval,intervals_list),]$interval_steps_mean
```

Group and summarize new data by date

```r
data_new_by_day <- data_new %>%
  group_by(date)  %>%
  summarize(daily_steps_total=sum(steps))
```

*Make a histogram of the total number of steps taken each day*

```r
with(data_new_by_day,
     hist(daily_steps_total,
          main="Histogram - NA's replaced with Interval mean",
          xlab="Total Daily Steps",
          col="red"))
```

![](PA1_template_files/figure-html/data_new_by_day_hist-1.png) 

*Calculate mean and median total number of steps taken per day.*

```r
daily_new_steps_mean <- mean(data_new_by_day$daily_steps_total)
daily_new_steps_median <- median(data_new_by_day$daily_steps_total)

mean_new_vs_raw <- identical(daily_new_steps_mean,daily_nona_steps_mean)
```

After replacing NAs with the median step per interval, the mean total number of steps taken per day is **10766.1887** (rounded to 4 decimal places), with a median of **10766.1887** steps (rounded to 4 decimal places). There is no difference in the means between the dataset with ignored NAs and the dataset with imputed NAs (The means are displayed here to 4 decimal places, but running identical() on them returns: **TRUE**). Likewise, the difference in medians is very small (**10766.1887** vs **10765** (rounded to 4 decimal places)). Therefore, I believe that we can state that there is no impact when using mean/interval to impute missing data.


## Are there differences in activity patterns between weekdays and weekends?

*Create a new factor variable in the dataset with two levels - "weekday" and "weekend" indicating whether a given date is a weekday or weekend day.*

```r
# add new variable "day_type", initialized to POSIX wday integer
data_new$day_type <- as.POSIXlt(data_new$date,format="%Y-%m-%d")$wday

# day_type values in (0,6) indicate weekend, so change the value to "weekend"
data_new$day_type[data_new$day_type == 0 | data_new$day_type == 6] <- "weekend"

# day_type values in (1:5) indicate weekday, so change the value to "weekday"
data_new$day_type[data_new$day_type >= 1 & data_new$day_type <= 5] <- "weekday"

# change day_type to Factor
data_new$day_type <- as.factor(data_new$day_type)
```

Group and summarize new data by interval

```r
data_new_by_interval <- data_new %>%
  group_by(interval,day_type)  %>%
  summarize(interval_steps_mean=mean(steps),
            interval_steps_total=sum(steps))
```

*Make a panel plot containing a time series plot (i.e. type = "l") of the 5-minute interval (x-axis) and the average number of steps taken, averaged across all weekday days or weekend days (y-axis).*

```r
library(ggplot2)
# create ggplot
thisplot <- ggplot(data_new_by_interval, aes(interval,interval_steps_mean)) +
  geom_line() +
  facet_wrap( ~ day_type, ncol=1) +
  ylab("Average steps") +
  ggtitle("Average steps/interval - weekday vs weekend") +
  theme(panel.margin = unit(1, "lines"))

print(thisplot)
```

![](PA1_template_files/figure-html/data_new_by_interval_tsplot-1.png) 

