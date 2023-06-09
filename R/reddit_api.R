# Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(jsonlite)
## Making sure small p-values are not displayed in scientific notation
options(scipen = 999) 

# Data Import and Cleaning

## Downloading reddit data 
rstats_list = fromJSON("https://www.reddit.com/r/rstats/.json") 

## Selecting required key/field containing post, upvotes, comments info 
rstats_original_tbl = rstats_list$data$children$data

## Use transmute() to select and rename columns at the same time to create rstats_tbl
rstats_tbl = rstats_original_tbl %>% 
  transmute(post = title,
            upvotes = ups, 
            comments = num_comments) 



# Visualization
rstats_tbl %>% ggplot(aes(x = upvotes, y = comments)) + 
  geom_point(method = "lm") +  # added in linn
  labs(x = "No. of Upvotes", 
       y = "No. of Comments",
       title = "Relationship between Upvotes and Comments")



# Analysis 
## cor.test() displays correlation statistic and p-value
cor_upvote_comment = cor.test(x = rstats_tbl$upvotes, y = rstats_tbl$comments)
cor_upvote_comment$estimate
cor_upvote_comment$p.value


# Publication 
## The correlation betweeen upvotes and comments was r(23) = .16, p = .43. This test was not statistically significant.

## Cleaning correlation output (i.e., rounding & removing leading zeroes) to output required text
cor_output = tibble(df = cor_upvote_comment$parameter, 
                    estimate = round(cor_upvote_comment$estimate, digits = 2),
                    pval = round(cor_upvote_comment$p.value, digits = 2)) %>% 
  mutate(sig_flag = ifelse(pval <= .05, " ", " not "),
         across(-df, ~ str_replace_all(.x, pattern = "^0", replacement = "")))
         
## Constructing the outputted line of text dynamically
paste0("The correlation betweeen upvotes and comments was r(",
       cor_output$df, 
       ") = ", 
       cor_output$estimate,
       ", p = ",
       cor_output$pval,
       ". This test was",
       cor_output$sig_flag,
       "statistically significant.")



# Notes:
## It is common for html and json files for not conform to dfs because
## flatten: changing structure. The dataframe has been collapsed, kind variable is ditributed among all the cases. 
## You can also pull upvotes and downvotes!!!

## sprintf allows formatting: can suppress leading zeroes
### sprintf("r(%d)=%2f", 24, .08), f stands for fixedpoint decimal notation
## format(round(estimate, 2), nsmall = 2) --> This is what I need! 
## Removing str_remove("0.012", "^\\d")

## Should split line if it passes the grey line (standard terminal width)
