# Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(rvest)

# Data Import and Cleaning
rstats_html = read_html("https://old.reddit.com/r/rstats/")


## Generating xpaths for the three variables
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

## Creating required variable  
rstats_tbl = tibble(post, upvotes, comments)

# Visualization
rstats_tbl %>% ggplot(aes(x = upvotes, y = comments)) + 
  geom_point() + 
  labs(x = "No. of Upvotes", 
       y = "No. of Comments",
       title = "Relationship between Upvotes and Comments")

# Analysis 
(cor_upvote_comment2 = cor.test(x = rstats_tbl$upvotes, y = rstats_tbl$comments))

# Publication 
# The correlation betweeen upvotes and comments was r(22) = .41, p = .04. This test was statistically significant.

## Removing leading zeroes in output and rounding 
cor_output2 = tibble(df = cor_upvote_comment2$parameter, 
                    estimate = round(cor_upvote_comment2$estimate, digits = 2),
                    pval = round(cor_upvote_comment2$p.value, digits = 2)) %>% 
  mutate(across(-df, ~ str_replace_all(.x, pattern = "^0", replacement = "")))
sig_flag2 = ifelse(cor_output2$pval <= .05, " ", " not") 

## Constructing the outputted line of text dynamically
paste0("The correlation betweeen upvotes and comments was r(",
       cor_output2$df, ") = ", cor_output2$estimate, ", p = ", cor_output2$pval,
       ". This test was", sig_flag2, "statistically significant.")



