## ######################################################################### ##
## Cellphone for dad
## ######################################################################### ##

#devtools::install_github("ingonader/rgeizhals", build_vignettes = TRUE)

library(rvest)
library(stringr)
library(rgeizhals)
library(dplyr)

options(tibble.width = Inf)

## ========================================================================= ##
## get data from geizhals
## ========================================================================= ##

##load("cellphone-2018-10-dad.Rdata")

url_gh <- "https://geizhals.at/?cat=umtsover&xf=11111_6.0~148_Android~157_16384~2392_5.0~2607_1536"
dat_gh <- get_geizhals_data(url_gh)

dat_gh

## didn't work; error message:
## > Error: Duplicate identifiers for rows (3, 4, 5)
## Hypothesis: duplicate URL in two consecutive list pages?

## fetch html of all listing pages:
listpagehtml_list <- fetch_all_listpages(url_gh)

## and parse information of these listing pages:
dat_listpage <- parse_all_listpages(listpagehtml_list)
head(dat_listpage)

## get all (or some) detailpages:
detailpagehtml_list <- fetch_all_detailpage_html(dat_listpage$detailpage_url)
dat_detailpage <- parse_all_detailpages(detailpagehtml_list)

n <- 34
detailpagehtml_list_part = list(url = detailpagehtml_list$url[1:n],
                                html = detailpagehtml_list$html[1:n])

dat_detailpage <- parse_all_detailpages(detailpagehtml_list_part)
dat_detailpage

parse_single_detailpage(detailpagehtml_list$html[[35]]) %>% print(n = 35)

#save.image("cellphone-2018-10-dad.Rdata")







