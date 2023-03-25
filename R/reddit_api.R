# Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(jsonlite)
options(scipen = 999)

# Data Import and Cleaning
rstats_list = fromJSON("https://www.reddit.com/r/rstats/.json") 
rstats_original_tbl = rstats_list$data$children$data

rstats_tbl = rstats_original_tbl %>% 
  transmute(post = title,
            upvotes = ups, 
            comments = num_comments) 

# Visualization
rstats_tbl %>% ggplot(aes(x = upvotes, y = comments)) + 
  geom_point() + 
  labs(x = "No. of Upvotes", 
       y = "No. of Comments",
       title = "Relationship between Upvotes and Comments")

# Analysis 
(cor_upvote_comment = cor.test(x = rstats_tbl$upvotes, y = rstats_tbl$comments))

# Publication 
## The correlation betweeen upvotes and comments was r(23) = .38, p = .06

## Removing leading zeroes in output and rounding 
cor_output = tibble(df = cor_upvote_comment$parameter, 
                    estimate = round(cor_upvote_comment$estimate, digits = 2),
                    pval = round(cor_upvote_comment$p.value, digits = 2)) %>% 
  mutate(across(-df, str_replace_all, pattern = "^0", replacement = ""))

## Constructing the outputted line of text dynamically
paste0("The correlation betweeen upvotes and comments was r(",
       cor_output$df, ") = ", cor_output$estimate, ", p = ", cor_output$pval)