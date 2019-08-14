#!/usr/bin/Rscript

library(here)
library(rvest)
library(tidyverse)
library(lubridate)


# Get wd of script
if (Sys.info()[['nodename']] == 'bigfoot') {
  setwd("/home/srvander/Projects/Misc/ISU_Crime_Data")
} else {
  setwd(here::here())
}

new_log <- read_html("https://www.police.iastate.edu/crime-log/") %>%
  html_nodes("a.log") %>%
  html_attr("href")

# get past files
# dates <- lubridate::today() - lubridate::days(1:30)
# new_logs <- sprintf("http://www.police.iastate.edu/wp-content/uploads/%d/%d/%d-Crime-Log-%d_%d_%d.pdf",
#                     year(dates), month(dates), year(dates), month(dates), day(dates), year(dates) %% 2000)
# download.file(new_logs, destfile = paste0(dates, ".pdf"), mode = 'wb')
download.file(new_log, destfile = paste0(lubridate::today(), ".pdf"), mode = 'wb')
#
# library(tabulizer)
#
# tabs <- tabulizer::extract_tables(new_log)
#
# nm <- c("Case Number", "Classification", "Date Reported", "Time Reported", "Earliest Occurrence Date", "Earliest Occurrence Time", "Latest Occurrence Date", "Latest Occurrence Time", "General Location", "Disposition")
# new_data <- purrr::map_df(tabs, as_tibble) %>%
#   select(which(colSums(!is.na(.)) > 0))
#   set_names(nm) %>%
#   filter(`Case Number` != "Case Number") %>%
#   mutate_all(str_trim) %>%
#   mutate_at(vars(matches("Time")), str_replace_na, replacement = "0000") %>%
#   mutate_at(vars(matches("Time")), ~sprintf("%04d", as.numeric(.))) %>%
#   mutate_all(str_trim) %>%
#   mutate_all(str_remove, pattern = "^\\s{0,}NA\\s{0,}$") %>%
#   mutate(`Date/Time Reported` = paste(`Date Reported`, `Time Reported`),
#          `Earliest Occurrence` = paste(`Earliest Occurrence Date`, `Earliest Occurrence Time`),
#          `Latest Occurrence` = paste(`Latest Occurrence Date`, `Latest Occurrence Time`)) %>%
#   select(1:2, 11, 12, 13, 9:10) %>%
#   mutate(scraped = lubridate::today())
#
# # new_data <- read_html("http://www.police.iastate.edu/content/daily-crime-log") %>%
# #   html_node("table") %>%
# #   html_table() %>%
# #   mutate(scraped = lubridate::today())
#
# if (file.exists("isu_crime_data.csv")) {
#   data <- read_csv("isu_crime_data.csv") %>%
#     mutate_if(.predicate = is.character, funs(str_replace_na), replacement = "") %>%
#     bind_rows(new_data) %>%
#     group_by_at(1:7) %>%
#     summarize(scraped = min(scraped))
#   data <- data[rowSums(data[,1:7] == "") < 7, ]
#   write_csv(data, "isu_crime_data.csv", append = F)
# } else {
#   write_csv(new_data, "isu_crime_data.csv", append = F)
# }
#
# system("git commit -a -m 'Automatic Update'")
# system("git push")

httr::GET("https://hc-ping.com/937c2355-d57a-462f-9605-f11cd9f1afa2")
