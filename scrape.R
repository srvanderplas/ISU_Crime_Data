#!/usr/bin/Rscript

library(here)
library(rvest)
library(tidyverse)

# Get wd of script
if (Sys.info()[['nodename']] == 'bigfoot') {
  setwd("/home/srvander/Projects/Misc/ISU_Crime_Data")
} else {
  setwd(here::here())
}

new_data <- read_html("http://www.police.iastate.edu/content/daily-crime-log") %>%
  html_node("table") %>%
  html_table() %>%
  mutate(scraped = lubridate::today())

if (file.exists("isu_crime_data.csv")) {
  data <- read_csv("isu_crime_data.csv") %>%
    mutate_if(.predicate = is.character, funs(str_replace_na(""))) %>%
    bind_rows(new_data) %>%
    group_by_at(1:7) %>%
    summarize(scraped = min(scraped))
  write_csv(data, "isu_crime_data.csv", append = F)
} else {
  write_csv(new_data, "isu_crime_data.csv", append = F)
}

system("git commit -a -m 'Automatic Update'")
system("git push")
