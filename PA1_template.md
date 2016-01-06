# Reproducible Research: Peer Assessment 1
Gene Kaufman, based on template cloned from [http://github.com/rdpeng/RepData_PeerAssessment1](http://github.com/rdpeng/RepData_PeerAssessment1)  
## Loading and preprocessing the data
First, we're going to set some global options (shamelessly copied from video notes)

```r
require(knitr)
```

```
## Loading required package: knitr
```

```r
opts_chunk$set(echo=TRUE, results="asis")
```

Download data file, if necessary

```r
zip_file_url<-"https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip"
zip_file_local<-"repdata_data_activity.zip"
if (!file.exists(zip_file_local)) {
  download.file(zip_file_url,destfile = zip_file_local,mode="wb")
}
```



## What is mean total number of steps taken per day?



## What is the average daily activity pattern?



## Imputing missing values



## Are there differences in activity patterns between weekdays and weekends?
