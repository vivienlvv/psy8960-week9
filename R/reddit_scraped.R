# Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(rvest)
library(str)

# Data Import and Cleaning
rstats_html = read_html("https://old.reddit.com/r/rstats/")

## Note: Ads are scraped here
post = html_elements(rstats_html, css = "a.title.may-blank") %>% html_text()
upvotes = html_elements(rstats_html, css = "div.score.unvoted") %>% 
  html_text() %>% 
  as.numeric() # NA means hidden
  
comments = html_elements(rstats_html, xpath = "//div[@class = 'entry unvoted']//li[position() = 1]") %>% 
  html_text() %>% 
  str_replace_all(pattern = "^comment$", replacement = "0") %>% 
  str_extract(pattern = "\\d+") %>% 
  as.numeric() # NA means ads
  
rstats_tbl = tibble(post, upvotes, comments)

# Visualization
rstats_tbl %>% ggplot(aes(x = upvotes, y = comments)) + 
  geom_point() + 
  labs(x = "No. of Upvotes", 
       y = "No. of Comments",
       title = "Relationship between Upvotes and Comments")

# Analysis 
cor.test(x = rstats_tbl$upvotes, y = rstats_tbl$comments)

# Publication (Section 6- confused by instructions, need to come back)
# The correlation between upvotes and comments was r(X) = .XX, p = .XX

