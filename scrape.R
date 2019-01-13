#!/usr/bin/Rscript

library(rvest)
library(tidyverse)

new_data <- read_html("http://www.police.iastate.edu/content/daily-crime-log") %>%
  html_node("table") %>%
  html_table() %>%
  mutate(scraped = lubridate::today())

if (file.exists("isu_crime_data.csv")) {
  data <- read_csv("isu_crime_data.csv") %>%
    bind_rows(new_data) %>%
    group_by_at(1:7) %>%
    summarize(scraped = min(scraped))
  write_csv(data, "isu_crime_data.csv", append = F)
} else {
  write_csv(new_data, "isu_crime_data.csv", append = F)
}

