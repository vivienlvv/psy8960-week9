# Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(rvest)

# Data Import and Cleaning
rstats_html = read_html("https://old.reddit.com/r/rstats/")

## Note: Ads are scraped here
post = html_elements(rstats_html, css = "a.title.may-blank") %>% html_text()
upvotes = html_elements(rstats_html, css = "div.score.unvoted") %>% html_text()
comments = html_elements(rstats_html, css = "li.first") %>% html_text() # Issue: Ads don't have comments

rstats_tbl = tibble(post, upvotes, comments)


# a.title.may-blank.outbound | p.title
# a.title.may-blank 