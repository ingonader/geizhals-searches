## ######################################################################### ##
## Camera lenses
## ######################################################################### ##

#devtools::install_github("ingonader/rgeizhals", build_vignettes = TRUE)

library(rvest)
library(stringr)
library(rgeizhals)
library(dplyr)
library(readr)

options(tibble.width = Inf)

## ========================================================================= ##
## get data from geizhals
## ========================================================================= ##

url_gh <- list(
  canon_efs = "https://geizhals.at/?cat=acamobjo&xf=8219_Canon+EF-S",
  canon_ef = "https://geizhals.at/?cat=acamobjo&xf=8219_Canon+EF",
  canon_rf = "https://geizhals.at/?cat=acamobjo&xf=8219_Canon+RF",
  sony_e = "https://geizhals.at/?cat=acamobjo&xf=8219_Sony+E",
  mft = "https://geizhals.at/?cat=acamobjo&xf=8219_Micro-Four-Thirds"
)

## first, get listpage data with all detailpage urls:
dat_listpage <- purrr::map(url_gh, get_listpage_data)

## check:
dat_listpage[["canon_efs"]]
dat_listpage[["canon_ef"]]
dat_listpage[["canon_rf"]]
dat_listpage[["sony_e"]]

## combine into single data.frame:
dat_listpage_tmp <- bind_rows(dat_listpage)
dat_listpage_tmp <- bind_cols(
  "csys" = rep(names(dat_listpage), purrr::map(dat_listpage, ~ nrow(.x))),
  dat_listpage_tmp)
dat_listpage_tmp %>% tail()

n_max <- length(dat_listpage_tmp[["detailpage_url"]])
n_max

## [[todo]]:
## * build some kind of mechanism to get chunks of data
##   into rgeizhals package

## then, fetch all detailpages in chunks (html only):
n <- 150
# pos_start <- - n + 1; detailpagehtml_list_html <- list() ## start from pos_start = 1

pos_start <- pmin(pos_start + n, n_max)
pos_end <- pmin(pos_start + (n - 1), n_max)
message(pos_start, " to ", pos_end)
detailpagehtml_list_html[pos_start : pos_end] <- 
  fetch_all_detailpage_html(
    dat_listpage_tmp[["detailpage_url"]][pos_start : pos_end])[["html"]]

## when done, add corresponding url's:
detailpagehtml_list <- list(
  url = dat_listpage_tmp[["detailpage_url"]][1 : pos_end],
  html = detailpagehtml_list_html[1 : pos_end]
)

detailpagehtml_list





## ///// OLD: ////////////////////

## currently can't use apply function: too many requests
# dat_gh_list <- purrr::map(url_gh, 
#                  get_geizhals_data)

dat_gh_list <- list()
dat_gh_list$canon_efs <-  get_geizhals_data(url_gh[["canon_efs"]])
dat_gh_list$canon_ef <-   get_geizhals_data(url_gh[["canon_ef"]])
dat_gh_list$canon_rf <-   get_geizhals_data(url_gh[["canon_rf"]])
#dat_gh_list$sony_e  <-    get_geizhals_data(url_gh[["sony_e"]])
#dat_gh_list$mft <-        get_geizhals_data(url_gh[["mft"]])

names(dat_gh_list)

## need to add missing data from new geizhals query:
dat_gh_list[["canon_ef"]]["Lichtstärke"] %>% pull()
