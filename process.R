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

activity_raw<-read.csv(data_file)
unlink(data_file)
library(dplyr)
activity_processed<-activity_raw %>%
  filter(!is.na(steps)) %>%
  group_by(date)
activity_processed_daily<-activity_processed  %>%
  summarize(daily_steps_mean=mean(steps),
            daily_steps_total=sum(steps))
#  mutate(DailyStepsMean=mean(steps))
message("What is mean total number of steps taken per day?")
daily_mean_steps<-mean(activity_processed_daily$daily_steps_total)
daily_median_steps<-median(activity_processed_daily$daily_steps_total)

mean_steps<-mean(activity_processed$steps)

with(activity_processed_daily,
     hist(daily_steps_total,breaks = 20))

activity_interval<-activity_raw %>%
  filter(!is.na(steps)) %>%
  group_by(interval)
activity_interval_summary<-activity_interval  %>%
  summarize(interval_steps_mean=mean(steps),
            interval_steps_total=sum(steps))

activity_interval_sorted<-activity_interval_summary  %>%
  arrange(desc(interval_steps_total),interval )

message("Which 5-minute interval, on average across all the days in the dataset, contains the maximum number of steps?")
max_interval_steps<-activity_interval_sorted[[1,1]]

head(activity_interval_sorted)
message("What is the average daily activity pattern?")
with(activity_interval_summary,
     plot(interval,interval_steps_mean,type="l"))

max(activity_interval_summary$interval_steps_total)


##################
message("Imputing missing values")

# strategy: replace NA steps with median for that interval
# 1. get median/interval (activity_interval_summary)

missing_steps_index <- is.na(activity_raw$steps)
msi<-missing_steps_index
intervals<-unique(activity_raw$interval)
ais<-activity_interval_summary

activity_imputed<-activity_raw
ai<-activity_imputed
ai$steps[which(msi)] <- ais$interval_steps_mean[match(ai$interval[which(msi)],intervals)]
#ai$steps[which(msi)] <- ais[match(ai$interval[which(msi)], interval)]
