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

data_nona_by_interval<-data_raw %>%
  filter(!is.na(steps)) %>%
  group_by(interval)  %>%
  summarize(interval_steps_mean=mean(steps),
            interval_steps_total=sum(steps))

na_steps_ndx <- is.na(data_raw$steps)
intervals_list<-unique(data_raw$interval)


data_new<-data_raw
# data_new$steps[which(na_steps_ndx)] <-
#   data_nona_by_interval$interval_steps_mean[match(data_new$interval[which(na_steps_ndx)],intervals_list)]

get_interval_mean<-function(interval_in){
  data_nona_by_interval$interval_steps_mean[data_nona_by_interval$interval == interval_in]
}

data_new$steps <- ifelse(is.na(data_new$steps),get_interval_mean(data_new$interval),data_new$steps)
