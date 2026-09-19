

# Load the data
library(tidyverse)
video_view <- read_csv("data/video_view.csv")
user_view <- read_csv("data/user_view.csv")
videos <- read_csv("data/videos.csv")
creators <- read_csv("data/creators.csv")
users <- read_csv("data/users.csv")
impressions <- read_csv("data/impressions.csv")
watch_events <- read_csv("data/watch_events.csv")
sessions <- read_csv("data/sessions.csv")

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
topwatched <- video_features %>% 
  select(watch_rate_rank, impressions_n, reach_band) %>% 
  arrange(watch_rate_rank)
head(topwatched, 10)

glimpse(video_features)

# Exercise 2
## Creator Summary
creator_summary <- video_features %>% 
  group_by(creator_id) %>% 
  summarise(
    videos_n = n(),
    impressions_total = sum(impressions_n, na.rm = TRUE), 
    watched_total = sum(watched_n, na.rm = TRUE),
    avg_watch_rate = mean(watch_rate, na.rm = TRUE),
    median_watch_seconds = median(total_watch_seconds, na.rm = TRUE)
  ) %>% 
  arrange(desc(impressions_total))
creator_summary

## Engagement by band
engagement_by_band <- video_features %>% 
  group_by(reach_band) %>% 
  summarise(
    videos_n = n(),
    avg_watch_rate = mean(watch_rate, na.rm = TRUE)
  )
engagement_by_band

write_csv(creator_summary, "temp/creator_summary.csv")
write_csv(engagement_by_band, "temp/engagement_by_band.csv")

# Exercise 3
## video_enriched
video_enriched <- video_features %>% 
  left_join(videos, by = c("video_id", "creator_id")) %>% 
  left_join(creators, by = "creator_id") %>% 
  select(video_id, creator_id, creator_name, impressions_n, watch_rate_rank, quality, posting_rate, publish_time)

video_enriched

## user_enriched
user_enriched <- user_view %>% 
  left_join(users, by = "user_id") %>% 
  select(user_id, user_name.x, user_handle.x, base_videos_watched_mean, base_videos_watched_sd)
user_enriched

write_csv(video_enriched, "temp/video_enriched.csv")

write_csv(user_enriched, "temp/user_enriched.csv")

# Exercise 4
#Many Issues with the joining due to identical column names
#which leads to columns changing names and therefore joining not possible
watch_log <- impressions %>%
  left_join(
    watch_events %>% 
      rename(watch_seconds_video = watch_seconds) %>%
      select(-session_id, -user_id, -video_id, -creator_id),
    by = "impression_id"
  ) %>%
  left_join(
    sessions %>% 
      rename(watch_seconds_session = watch_seconds),
    by = c("session_id", "user_id")
  ) %>%
  left_join(videos, by = c("video_id", "creator_id")) %>%
  left_join(creators, by = "creator_id")


watched_only <- impressions %>%
  inner_join(watch_events, by = "impression_id")

creator_event_summary <- watch_log %>%
  group_by(creator_id) %>%
  summarise(
    impressions = n(),
    watched_events = sum(!is.na(action)),
    total_watch_seconds = sum(watch_seconds_video, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(watch_log, "temp/watch_log.csv")
write_csv(creator_event_summary, "temp/creator_event_summary.csv")

# Example
watch_time_preview <- watch_log %>%
  mutate(
    shown_ts = as.POSIXct(shown_at,
                          format = "%Y-%m-%dT%H:%M:%SZ",
                          tz = "UTC"),
    shown_day = as.Date(shown_ts)
  ) %>%
  select(impression_id, creator_id, shown_at, shown_ts, shown_day) %>%
  head(8)

creator_daily <- watch_log %>%
  mutate(shown_ts = as.POSIXct(shown_at, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")) %>% 
  mutate(shown_day = as.Date(shown_ts)) %>%
  count(creator_id, shown_day, name = "impressions_n") %>%
  group_by(creator_id) %>%
  arrange(shown_day) %>%
  mutate(impressions_lag1 = lag(impressions_n))

# Exercise 5
creator_daily2 <- watch_log %>% 
  mutate(shown_ts = as.POSIXct(shown_at, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")) %>% 
  mutate(shown_day = as.Date(shown_ts)) %>%
  count(creator_id, shown_day, name = "impressions_n") %>%
  mutate(impressions_lag1 = lag(impressions_n)) %>% 
  mutate(impressions_change = impressions_n - impressions_lag1)

write_csv(creator_daily, "temp/creator_daily_week4.csv")
