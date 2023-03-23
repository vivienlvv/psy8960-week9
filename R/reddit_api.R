# Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(jsonlite)
# library(httr)
# library(rvest)
options(scipen = 999)

# Data Import and Cleaning
rstats_list = fromJSON("https://www.reddit.com/r/rstats/.json") 
rstats_original_tbl = rstats_list$data$children$data

rstats_tbl = tibble(post = rstats_original_tbl$title,
                    upvotes = rstats_original_tbl$ups,
                    comments = rstats_original_tbl$num_comments)

# Visualization
rstats_tbl %>% ggplot(aes(x = upvotes, y = comments)) + 
  geom_point() + 
  labs(x = "No. of Upvotes", 
       y = "No. of Comments",
       title = "Relationship between Upvotes and Comments")

# Analysis 
cor.test(x = rstats_tbl$upvotes, y = rstats_tbl$comments)

# Publication (Section 6- confused by instructions, need to come back)
# The correlation between upvotes and comments was r(23) = .75, p < .00




# Useless content to delete later
# temp = read_html("https://www.reddit.com/r/rstats/")
# tbl = tibble(post = html_text(html_elements(temp, "div.STit0dLageRsa2yR4te_b")),
#              upvotes = html_text(html_elements(temp, "div._1rZYMD_4xY3gRcSS3p8ODO._3a2ZHWaih05DgAOtvu6cIo")),
#              comments = html_text(html_elements(temp, "span.FHCV02u6Cp2zYL0fhQPsO")))