# Exercise 6

library(tidyverse)

dir.create("temp", showWarnings = FALSE)

video_view <- read_csv("data/video_view.csv")
creators <- read_csv("data/creators.csv")

creator_week4 <- video_view %>% 
  left_join(creators, by = "creator_id") %>% 
  group_by(creator_id) %>% 
  summarise(
    videos_n = n(),
    impressions_total = sum(impressions_n, na.rm = TRUE),
    watched_total = sum(watched_n, na.rm = TRUE),
    avg_watch_rate = mean(watch_rate, na.rm = TRUE)
  )
write_csv(creator_week4, "temp/creator_week4.csv")

