# load packages
library(tidyverse)
library(RSelenium)
library(netstat)

# start the server
rs_driver_object <- rsDriver(browser = 'chrome',
                             chromever = '97.0.4692.71',
                             verbose = FALSE,
                             port = free_port())

# create a client object
remDr <- rs_driver_object$client

# open a browser
remDr$open()

# maximize window
remDr$maxWindowSize()

# navigate to website
remDr$navigate('https://www.ebay.com')

# finding elements
electronics_object <- remDr$findElement(using = 'link text', 'Electronics')
electronics_object$clickElement()

# go back
remDr$goBack()

# search for an item
search_box <- remDr$findElement(using = 'id', 'gh-ac')
search_box$sendKeysToElement(list('Playstation 5', key = 'enter'))

# scroll to the end of the webpage
remDr$executeScript("window.scrollTo(0, document.body.scrollHeight);")

# click on the United States filter box
us_checkbox <- remDr$findElement(using = 'xpath', '//input[@aria-label="United States"]')
us_checkbox$clickElement()

us_checkbox$refresh()

# click on the color dropdown
remDr$findElement(using = 'xpath', '//*[text()="Color"]')$clickElement()

# click on the white color
remDr$findElement(using = 'xpath', '//input[@aria-label="White"]')$clickElement()

# identify the price 
prices <- remDr$findElements(using = 'class name', 's-item__price')

price_values <- lapply(prices, function (x) x$getElementText()) %>% 
  unlist() %>% 
  str_remove_all('[$]')

price_values = price_values[-33]

# convert from number to string
price_values = price_values %>% 
  as.numeric()

mean(price_values)
median(price_values)


# terminate the selenium server
system("taskkill /im java.exe /f")
