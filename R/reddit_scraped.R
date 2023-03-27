# Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(rvest)
## Making sure small p-values are not displayed in scientific notation
options(scipen = 999)  

# Data Import and Cleaning

rstats_html = read_html("https://old.reddit.com/r/rstats/")

## Generating xpaths for the three variables
xpath_post = "//div[contains(@class, 'odd') or contains(@class, 'even')]//a[contains(@class, 'title may-blank')]"
xpath_upvotes = "//div[contains(@class, 'odd') or contains(@class, 'even')]//div[@class = 'score unvoted']"
xpath_comments = "//div[contains(@class, 'odd') or contains(@class, 'even')]//div[@class = 'entry unvoted']//li[position() = 1]"

## Creating vectors for constructing tibble later
post = html_elements(rstats_html, xpath = xpath_post) %>% html_text()
upvotes = html_elements(rstats_html, xpath = xpath_upvotes) %>% 
  html_text() %>% 
  as.numeric() # NA means hidden posts, which will be dropped by ggplot() and cor.test() automatically
comments = html_elements(rstats_html, xpath = xpath_comments) %>% 
  html_text() %>% 
  str_replace_all(pattern = "^comment$", replacement = "0") %>% 
  str_extract(pattern = "\\d+") %>% 
  as.numeric() 

## Creating required variable rstats_tbl 
rstats_tbl = tibble(post, upvotes, comments)



# Visualization
rstats_tbl %>% ggplot(aes(x = upvotes, y = comments)) + 
  geom_point() + 
  labs(x = "No. of Upvotes", 
       y = "No. of Comments",
       title = "Relationship between Upvotes and Comments")



# Analysis 
cor_upvote_comment2 = cor.test(x = rstats_tbl$upvotes, y = rstats_tbl$comments)
cor_upvote_comment2$estimate
cor_upvote_comment2$p.value



# Publication 
## The correlation betweeen upvotes and comments was r(21) = .15, p = .49. This test was not statistically significant.

## Cleaning correlation output (i.e., rounding & removing leading zeroes) to output required text
cor_output2 = tibble(df = cor_upvote_comment2$parameter, 
                    estimate = round(cor_upvote_comment2$estimate, digits = 2),
                    pval = round(cor_upvote_comment2$p.value, digits = 2)) %>% 
  mutate(sig_flag = ifelse(pval <= .05, " ", " not "),
         across(-df, ~ str_replace_all(.x, pattern = "^0", replacement = "")))

## Constructing the outputted line of text dynamically
paste0("The correlation betweeen upvotes and comments was r(",
       cor_output2$df, ") = ", cor_output2$estimate, ", p = ", cor_output2$pval,
       ". This test was", cor_output2$sig_flag, "statistically significant.")

