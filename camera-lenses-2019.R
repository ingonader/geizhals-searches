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
