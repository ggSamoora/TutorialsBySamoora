# load the necessary packages
library(tidyverse)
library(RSelenium)
library(netstat)

# connecting to selenium server
rs_driver_object <- rsDriver(
  browser = 'chrome',
  chromever = "98.0.4758.102",
  verbose = F,
  port = free_port()
)

# access the client object
remDr <- rs_driver_object$client

# open a web browser
remDr$open()

# navigate to the Stats NZ website
remDr$navigate("https://www.stats.govt.nz/large-datasets/csv-files-for-download/")

# find the 'a' tags within the specified class name using the xpath method
data_files <- remDr$findElements(using = 'xpath', "//h3[@class='block-document__title']/a")

# return the names of the files
data_file_names <- lapply(data_files, function(x) {
  x$getElementText() %>% unlist()
}) %>% flatten_chr() %>% 
  str_remove_all("[:]")

# return the links to the files
data_file_links <- lapply(data_files, function(x) {
  x$getElementAttribute('href') %>% unlist()
}) %>% flatten_chr()

# the loop to download all the files
for (i in 1:length(data_file_names)) {
  download.file(
    url = data_file_links[i],
    destfile = paste0(data_file_names[i], gsub(x = data_file_links[i], pattern = ".*[.]", replacement = "."))
  )
}
