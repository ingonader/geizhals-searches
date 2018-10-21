## ######################################################################### ##
## Cellphone for dad
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

##load("cellphone-2018-10-dad.Rdata")

url_gh <- "https://geizhals.at/?cat=umtsover&xf=11111_6.0~148_Android~157_16384~2392_5.0~2607_1536"
dat_gh <- get_geizhals_data(url_gh)

dat_gh

#save.image("cellphone-2018-10-dad.Rdata")

## ========================================================================= ##
## data exploration
## ========================================================================= ##

names(dat_gh)
table(dat_gh[["Akku"]])
get_feature_summary(dat_gh, "Sensoren")
get_feature_summary(dat_gh, "Besonderheiten")
get_feature_summary(dat_gh, "Navigation")
get_feature_summary(dat_gh, "Schnittstellen")

#help(package = "rgeizhals")

## ========================================================================= ##
## add features
## ========================================================================= ##

## Akku wechselbar?
dat_gh[["akku_wechselbar"]] <- extract_feature_ind(dat_gh, col = "Akku", regex = "wechselbar")

## Akku-Kapazität:
dat_gh[["akku_kapazitaet"]] <- stringr::str_extract(dat_gh[["Akku"]], "^[0-9]+") %>% as.numeric()

## IPx-zertifiziert:
dat_gh[["ipx"]] <- extract_feature_ind(dat_gh, col = "Besonderheiten", regex = "IP6[0-9]{1}")
dat_gh[c("Besonderheiten", "ipx")]

## GLONASS GPS (at least):
dat_gh[["glonass"]] <- extract_feature_ind(dat_gh, col = "Navigation", regex = "GLONASS")

## ========================================================================= ##
## filter data
## ========================================================================= ##

#cat(paste(names(dat_gh), collapse = "\n"), "\n")
varnames_sel <- c(
  "prodname", 
  "rating", 
  "rating_n", 
  "offers_n", 
  "listprice", 
  "detailpage_url", 
  "Abmessungen", 
  "Akku", 
  "Besonderheiten", 
  "CPU", 
  "Display", 
  "Gelistet seit", 
  "Gesprächszeit", 
  "Gewicht", 
  "Navigation", 
  "OS", 
  "price_2nd_min", 
  "price_3rd_min", 
  "price_median", 
  "price_min", 
  "RAM", 
  "Schnittstellen", 
  "Sensoren", 
  "Speicher", 
  "Standby-Zeit", 
  "ipx"
)

dat_sel <- dat_gh %>% 
  filter(akku_kapazitaet >= 2500,
         glonass == 1,
         listprice <= 300)

dat_sel <- dat_sel %>% arrange(desc(rating)) %>% print(n = 30)
write_csv(dat_sel, path = "cellpone-2018-10-dad.csv")

dat_sel[[varnames_sel]] %>% View()


