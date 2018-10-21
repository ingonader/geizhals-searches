## ######################################################################### ##
## Wäschetrockner
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

url_gh <- "https://geizhals.at/?cat=hwaeschtr&xf=1027_W%E4rmepumpentrockner%7E1296_10%7E1747_8%7E7641_40%7E7653_9"
dat_gh <- get_geizhals_data(url_gh)

dat_gh