#-------------------------------
library(tidyverse)  # data wrangling
library(RSelenium)  # activate Selenium server
library(rvest)      # web scrape tables
library(netstat)    # find unused port
library(data.table) # for the rbindlist function

rs_driver_object <- rsDriver(browser = "chrome",
                             chromever = "103.0.5060.53",
                             verbose = F,
                             port = free_port())

remDr <- rs_driver_object$client

remDr$open()
remDr$navigate("https://salaries.texastribune.org/search/?q=%22Department+of+Public+Safety%22")

data_table <- remDr$findElement(using = 'id', 'pagination-table')

all_data <- list()
cond <- TRUE

while (cond == TRUE) {
  data_table_html <- data_table$getPageSource()
  page <- read_html(data_table_html %>% unlist())
  df <- html_table(page) %>% .[[2]]
  all_data <- rbindlist(list(all_data, df))
  
  Sys.sleep(0.2)
  
  tryCatch(
    {
      next_button <- remDr$findElement(using = 'xpath', '//a[@aria-label="Next Page"]')
      next_button$clickElement()
    },
    error=function(e) {
      print("Script Complete!")
      cond <<- FALSE
    }
  )
  
  if (cond == FALSE){
    break
  }
}

colnames(all_data)[3] <- "Agency"

all_data$`Annual salary` <- str_remove_all(all_data$`Annual salary`, "[$,]") %>% 
  as.numeric()

write_csv(all_data, "Texas_Dept_of_Safety_Salaries.csv", na = "")
