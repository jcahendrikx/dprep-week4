# Load the data
library(tidyverse)
video_view <- read_csv("data/video_view.csv")
head(video_view)

# Exercise 1
video_features <- video_view %>% 
  mutate(watch_rate_rank = rank(-watch_rate)) %>% 
  mutate(reach_band = case_when(
    impressions_n < quantile(impressions_n, 1/3, na.rm = TRUE) ~ "Low",
    impressions_n < quantile(impressions_n, 2/3, na.rm = TRUE) ~ "Medium",
    TRUE                                                     ~ "High"
  )) %>% 
  mutate(high_quality = avg_watch_share >= 0.40) %>% 
  distinct(video_id, .keep_all = TRUE) 

write_csv(video_features, "temp/video_features.csv")
head(video_features)
video_features %>% select(impressions_n, reach_band)


# Exercise 2



# Exercise 3



# Exercise 4



# Exercise 5
