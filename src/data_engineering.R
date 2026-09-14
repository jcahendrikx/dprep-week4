# Load the data
video_view <- read_csv("data/video_view.csv")
head(video_view)

# Exercise 1
video_view <- video_view %>% 
  mutate(watch_rate_rank = rank(-watch_rate))
head(video_view)

# Exercise 2



# Exercise 3



# Exercise 4



# Exercise 5
