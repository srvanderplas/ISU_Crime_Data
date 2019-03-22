#!/usr/bin/Rscript

library(here)
library(rvest)
library(tidyverse)
library(tabulizer)

# Get wd of script
if (Sys.info()[['nodename']] == 'bigfoot') {
  setwd("/home/srvander/Projects/Misc/ISU_Crime_Data")
} else {
  setwd(here::here())
}

new_log <- read_html("https://www.police.iastate.edu/crime-log/") %>%
  html_nodes("a.log") %>%
  html_attr("href")

tabs <- extract_tables(new_log)

nm <- c("Case Number", "Classification", "Date Reported", "Time Reported", "Earliest Occurrence Date", "Earliest Occurrence Time", "Latest Occurrence Date", "Latest Occurrence Time", "General Location", "Disposition")
new_data <- purrr::map(tabs, as_tibble) %>%
  purrr::map(set_names, nm) %>%
  bind_rows() %>%
  filter(row_number() != 1) %>%
  mutate_all(str_trim) %>%
  mutate_at(vars(matches("Time")), str_replace_na, replacement = "0000") %>%
  mutate_at(vars(matches("Time")), ~sprintf("%04d", as.numeric(.))) %>%
  mutate_all(str_trim) %>%
  mutate_all(str_remove, pattern = "^\\s{0,}NA\\s{0,}$") %>%
  mutate(`Date/Time Reported` = paste(`Date Reported`, `Time Reported`),
         `Earliest Occurrence` = paste(`Earliest Occurrence Date`, `Earliest Occurrence Time`),
         `Latest Occurrence` = paste(`Latest Occurrence Date`, `Latest Occurrence Time`)) %>%
  select(1:2, 11, 12, 13, 9:10) %>%
  mutate(scraped = lubridate::today())

# new_data <- read_html("http://www.police.iastate.edu/content/daily-crime-log") %>%
#   html_node("table") %>%
#   html_table() %>%
#   mutate(scraped = lubridate::today())

if (file.exists("isu_crime_data.csv")) {
  data <- read_csv("isu_crime_data.csv") %>%
    mutate_if(.predicate = is.character, funs(str_replace_na), replacement = "") %>%
    bind_rows(new_data) %>%
    group_by_at(1:7) %>%
    summarize(scraped = min(scraped))
  data <- data[rowSums(data[,1:7] == "") < 7, ]
  write_csv(data, "isu_crime_data.csv", append = F)
} else {
  write_csv(new_data, "isu_crime_data.csv", append = F)
}

system("git commit -a -m 'Automatic Update'")
system("git push")
