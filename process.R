message("Loading and preprocessing the data")
zip_file_url<-"https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip"
zip_file_local<-"repdata_data_activity.zip"
data_file<-"activity.csv"
if (!file.exists(zip_file_local)) {
  download.file(zip_file_url,destfile = zip_file_local,mode="wb")
}
if (!file.exists(zip_file_local)) {
  stop("Failed to retrieve zip file!")
}
message("Unzipping data file")
unzip(zip_file_local)

data_raw<-read.csv(data_file)
unlink(data_file)
library(dplyr)

na_steps_ndx <- is.na(data_raw$steps)
intervals_list<-unique(data_raw$interval)

data_nona_by_day<-data_raw %>%
  filter(!is.na(steps)) %>%
  group_by(date)  %>%
  summarize(daily_steps_total=sum(steps))

message("What is mean total number of steps taken per day?")
daily_nona_steps_mean <-mean(data_nona_by_day$daily_steps_total)
daily_nona_steps_median<-median(data_nona_by_day$daily_steps_total)


with(data_nona_by_day,
     hist(daily_steps_total,
          main="Histogram - NA's ignored",
          xlab="Total Daily Steps",
          col="blue"))

data_nona_by_interval<-data_raw %>%
  filter(!is.na(steps)) %>%
  group_by(interval)  %>%
  summarize(interval_steps_mean=mean(steps),
            interval_steps_total=sum(steps))


message("Which 5-minute interval, on average across all the days in the dataset, contains the maximum number of steps?")
max_interval_steps<-intervals_list[which.max(data_nona_by_interval$interval_steps_total)]

message("What is the average daily activity pattern?")
with(data_nona_by_interval,
     plot(interval,interval_steps_mean,type="l"))


##################
message("Imputing missing values")

# strategy: replace NA steps with median for that interval
# 1. get median/interval (data_nona_by_interval)


data_new<-data_raw
data_new$steps[which(na_steps_ndx)] <- data_nona_by_interval$interval_steps_mean[match(data_new$interval[which(na_steps_ndx)],intervals_list)]
#data_new$day_type <- weekdays(as.POSIXlt(data_new$date,format="%Y-%m-%d"))
data_new$day_type <- as.POSIXlt(data_new$date,format="%Y-%m-%d")$wday
data_new$day_type[data_new$day_type == 0 | data_new$day_type == 6] <- "weekend"
data_new$day_type[data_new$day_type > 0 & data_new$day_type < 6] <- "weekday"
data_new$day_type <- as.factor(data_new$day_type)

data_new_by_day<-data_new %>%
  group_by(date)  %>%
  summarize(daily_steps_total=sum(steps))

data_new_by_interval<-data_new %>%
  group_by(interval,day_type)  %>%
  summarize(interval_steps_mean=mean(steps),
            interval_steps_total=sum(steps))

daily_new_steps_mean <-mean(data_new_by_day$daily_steps_total)
daily_new_steps_median<-median(data_new_by_day$daily_steps_total)

with(data_new_by_day,
     hist(daily_steps_total,
          main="Histogram - NA's replaced with Interval mean",
          xlab="Total Daily Steps",
          col="red"))

with(data_new_by_interval,
     plot(interval,interval_steps_mean,type="l"))


library(ggplot2)
# create ggplot
thisplot<-ggplot(data_new_by_interval, aes(interval,interval_steps_mean)) +
  geom_line() +
  facet_wrap( ~ day_type, ncol=1) +
  ylab("Average steps") +
  ggtitle("Average steps/interval - weekday vs weekend") +
  theme(panel.margin = unit(1, "lines"))

print(thisplot)
