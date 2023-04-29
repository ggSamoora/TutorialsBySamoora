# load the libraries
library(tidyverse)
library(Rcrawler)

# crawl ps5 game urls from the 'Games of All Time' page
Rcrawler(Website = "https://www.metacritic.com/browse/games/score/metascore/all/ps5/filtered",
         crawlUrlfilter = "/game/playstation-5/[^/]+$",
         no_cores = 4,
         no_conn = 4,
         MaxDepth = 1,
         saveOnDisk = FALSE)

# use this function to test out the scraping of html elements
ContentScraper(Url = "https://www.metacritic.com/game/playstation-5/elden-ring",
               XpathPatterns = c("//div[@class='product_title']/a/h1",
                                 "//div[starts-with(@class, 'metascore_w xlarge')]",
                                 "//div[starts-with(@class, 'metascore_w user')]"))

# crawl and scrape the contents of the ps5 games
Rcrawler(Website = "https://www.metacritic.com/browse/games/score/metascore/all/ps5/filtered",
         crawlUrlfilter = "/game/playstation-5/[^/]+$",
         dataUrlfilter = "/game/playstation-5/[^/]+$",
         crawlZoneXPath = "//td[@class='clamp-summary-wrap']",
         ExtractXpathPat = c("//div[@class='product_title']/a/h1",
                             "//div[starts-with(@class, 'metascore_w xlarge')]",
                             "//div[starts-with(@class, 'metascore_w user')]"),
         PatternsNames = c("title", "metascore", "user-score"),
         no_cores = 4,
         no_conn = 4,
         MaxDepth = 1,
         RequestsDelay = 0.1,
         saveOnDisk = FALSE)               

# convert the DATA list to a dataframe
df <- do.call("rbind", DATA) %>% data.frame()

# crawl for all the pages of the 'Games of All Time' section
Rcrawler(Website = "https://www.metacritic.com/browse/games/score/metascore/all/ps5/filtered",
         crawlUrlfilter = "?page=[0-9]+$",
         MaxDepth = 1,
         saveOnDisk = F)

# store the urls in an object
url_list <- INDEX$Url

# create a map_dfr function to loop through all the page urls to crawl and 
# scrape all the ps5 games
final_df <- map_dfr(url_list, ~{
  Rcrawler(Website = .,
           crawlUrlfilter = "/game/playstation-5/[^/]+$",
           dataUrlfilter = "/game/playstation-5/[^/]+$",
           crawlZoneXPath = "//td[@class='clamp-summary-wrap']",
           ExtractXpathPat = c("//div[@class='product_title']/a/h1",
                               "//div[starts-with(@class, 'metascore_w xlarge')]",
                               "//div[starts-with(@class, 'metascore_w user')]"),
           PatternsNames = c("title", "metascore", "user-score"),
           no_cores = 4,
           no_conn = 4,
           MaxDepth = 10,
           RequestsDelay = 0.1,
           saveOnDisk = FALSE) 
  
  df <- do.call("rbind", DATA) %>% data.frame()
})

# final cleaning of the dataframe
final_df <- final_df %>% 
  mutate(across(everything(), as.character)) %>% 
  mutate(across(everything(), ~replace(., . ==  "tbd" , NA))) %>% 
  mutate(across(c(metascore, user.score), as.numeric)) %>%
  mutate(PageID = 1:nrow(.)) %>% 
  tibble::remove_rownames() 
