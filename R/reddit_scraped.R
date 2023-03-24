# Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(rvest)

# Data Import and Cleaning
rstats_html = read_html("https://old.reddit.com/r/rstats/")

## Note: Ads are scraped here
# post = html_elements(rstats_html, css = "a.title.may-blank.outbound") %>% html_text()
# Generating xpaths for the three variables
xpath_post = "//div[contains(@class, 'odd') or contains(@class, 'even')]//a[contains(@class, 'title may-blank')]"
xpath_upvotes = "//div[contains(@class, 'odd') or contains(@class, 'even')]//div[@class = 'score unvoted']"
xpath_comments = "//div[contains(@class, 'odd') or contains(@class, 'even')]//div[@class = 'entry unvoted']//li[position() = 1]"
  
post = html_elements(rstats_html, xpath = xpath_post) %>% html_text()

upvotes = html_elements(rstats_html, xpath = xpath_upvotes) %>% 
  html_text() %>% 
  as.numeric() # NA means hidden
  
comments = html_elements(rstats_html, xpath = xpath_comments) %>% 
  html_text() %>% 
  str_replace_all(pattern = "^comment$", replacement = "0") %>% 
  str_extract(pattern = "\\d+") %>% 
  as.numeric() 
  
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

