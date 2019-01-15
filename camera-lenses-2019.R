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

dat_gh <- purrr::map(url_gh, 
                 get_geizhals_data)

