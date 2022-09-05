# load the necessary packages
library(tidyverse)
library(rvest)
library(data.table)
library(rlist)

# used for accumulating all reviews in one place
df_final <- list()

# find the number of pages
pageNums <- page %>% 
  html_elements(xpath = "//div[@aria-label='Pagination navigation']") %>% 
  html_text() %>% 
  str_extract('of \\d+') %>% 
  str_remove('of ') %>% 
  as.numeric()

# create a sequence based on the number of pages
# to be used in the URL for moving from one page to the other
pageSequence <- seq(from = 0, to = (pageNums * 10)-10, by=10)

# function to be used for extracting the extra information about a review
extra_info_extract <- function(ei, txt) {
  str_extract(ei, paste0(txt, ".*")) %>% 
    .[!is.na(.)] %>% 
    str_extract("\\d+") %>% 
    str_replace_na("0") %>% 
    as.numeric()
}

# beginning of for loop
for (i in pageSequence) {
  
  # create a formatted url object to reference correct page
  url <- sprintf("https://www.yelp.com/biz/sob-dallas?start=%d&sort_by=date_asc", i)
  
  # read the url as an html object
  page <- read_html(url)
  
  # collect all usernames from reviews
  usernames <- page %>% 
    html_elements(xpath = "//div[starts-with(@class, ' user-passport')]") %>% 
    html_elements(xpath = ".//a[starts-with(@href, '/user_details')]") %>% 
    html_text()
  
  # collect all locations of reviews
  locations <- page %>% 
    html_elements(xpath = "//div[starts-with(@class, ' user-passport')]") %>% 
    html_elements(xpath = ".//span[@class=' css-qgunke']") %>% 
    html_text() %>% 
    .[.!="Location"]
  
  # collect the review text
  comments <- page %>% 
    html_elements(xpath = "//div[starts-with(@class, ' review')]") %>% 
    html_elements(xpath = "(.//p[starts-with(@class, 'comment')])[1]") %>% 
    html_text()
  
  # collect the review ratings
  ratings <- page %>% 
    html_elements(xpath = "//div[starts-with(@class, ' review')]") %>% 
    html_elements(xpath = "(.//div[contains(@aria-label, 'star rating')])[1]") %>% 
    html_attr("aria-label") %>% 
    str_remove_all(" star rating") %>% 
    as.numeric()
  
  # collect the review dates
  the_dates <- page %>% 
    html_elements(xpath = "//div[starts-with(@class, ' review')]") %>% 
    html_elements(xpath = "(.//span[@class = ' css-chan6m'])[1]") %>% 
    html_text()
  
  # collect the extra information about the reviews (Useful, funny, cool)
  extra_info <- page %>% 
    html_elements(xpath = "//div[starts-with(@class, ' review')]") %>% 
    html_elements(xpath = ".//button[@type='submit']") %>% 
    html_text() %>% 
    .[.!=""] %>% 
    .[.!="Read more"]
  
  # assign the extra information accordingly
  useful <- extra_info_extract(extra_info, "Useful")
  funny <- extra_info_extract(extra_info, "Funny")
  cool <- extra_info_extract(extra_info, "Cool")
  
  # combine the objects into a list
  df_new <- list(username = usernames, 
                 dates = the_dates, 
                 location = locations,
                 rating = ratings,
                 comment = comments,
                 useful = useful,
                 funny = funny,
                 cool = cool)
  
  # convert the list into a data frame
  df_new_table <- as.data.frame(df_new)
  
  # append the data frame to the df_final object
  df_final <- rbindlist(list(df_final, df_new_table))
  
  # random sleep time set between pages to prevent the IP address from being banned
  Sys.sleep(sample(c(15,25), 1))
}

# write the dataset to a csv file
write_csv(df_final, "SOB Yelp Review.csv", na = "")
