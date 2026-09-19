# Exercise 6

library(tidyverse)

dir.create("output", showWarnings = FALSE)

creator_week4 <- read_csv("temp/creator_week4.csv")

creator_top10 <- creator_week4 %>% 
  arrange(desc(impressions_total)) %>% 
  head(10)

write_csv(creator_top10, "output/creatpr_top10_week4.csv")
