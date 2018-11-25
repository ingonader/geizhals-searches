## ######################################################################### ##
## NAS
## ######################################################################### ##

# rstudioapi::restartSession(); rm(list = ls(), inherits = TRUE)

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

##load("nas-2018-11.Rdata")

## Geizhals:
## NAS systems:
## https://geizhals.at/?cat=hdxnas
## without HDD for under 200 Euro:

url_gh <- "https://geizhals.at/?cat=hdxnas&xf=2659_ohne&asuch=&bpmin=&bpmax=200&v=e&hloc=at&filter=aktualisieren&plz=&dist=&mail=&sort=p&bl1_id=30"


## get data:
dat_gh <- get_geizhals_data(url_gh)
dat_gh

#save.image("nas-2018-11.Rdata")

## ========================================================================= ##
## data exploration
## ========================================================================= ##

names(dat_gh)
table(dat_gh[["Akku"]])
get_feature_summary(dat_gh, "Abmessungen (BxHxT)")
get_feature_summary(dat_gh, "Besonderheiten")
get_feature_summary(dat_gh, "Extern")
get_feature_summary(dat_gh, "Festplatte")
get_feature_summary(dat_gh, "Herstellergarantie")
get_feature_summary(dat_gh, "Intern")
get_feature_summary(dat_gh, "Leistungsaufnahme")
get_feature_summary(dat_gh, "Lüfter")
get_feature_summary(dat_gh, "Zusätzliche Anschlüsse")
get_feature_summary(dat_gh, "RAM")
get_feature_summary(dat_gh, "CPU")


#help(package = "rgeizhals")

## ========================================================================= ##
## add features
## ========================================================================= ##

dat_gh[["breite"]] <- dat_gh[["Abmessungen (BxHxT)"]] %>% 
  stringr::str_replace_all("mm", "") %>%
  stringr::str_split_fixed("[^0-9\\.]", n = 3) %>% .[, 1]

dat_gh[["hoehe"]] <- dat_gh[["Abmessungen (BxHxT)"]] %>% 
  stringr::str_replace_all("mm", "") %>%
  stringr::str_split_fixed("[^0-9\\.]", n = 3) %>% .[, 2]

dat_gh[["tiefe"]] <- dat_gh[["Abmessungen (BxHxT)"]] %>% 
  stringr::str_replace_all("mm", "") %>%
  stringr::str_split_fixed("[^0-9\\.]", n = 3) %>% .[, 3]

dat_gh[["usb3"]] <- extract_feature_ind(dat_gh, col = "Zusätzliche Anschlüsse", regex = "USB-A 3\\.0")
dat_gh[["usb2"]] <- extract_feature_ind(dat_gh, col = "Zusätzliche Anschlüsse", regex = "USB-A 2\\.0")
dat_gh[["cardreader"]] <- extract_feature_ind(dat_gh, col = "Zusätzliche Anschlüsse", regex = "Cardreader")


## ========================================================================= ##
## filter data
## ========================================================================= ##

#cat(paste(names(dat_gh), collapse = "\n"), "\n")
varnames_sel <- setdiff(names(dat_gh),
                        c(#"detailpage_url",
                          "Festplatte", 
                          "Gelistet seit",
                          "Gewicht",
                          "Herstellergarantie"))
## with cardreader:
dat_sel <- dat_gh %>% 
  filter(cardreader == 1)
dat_sel %>% as.matrix() %>% t()

## with both usb 3.0 and usb 2.0:
dat_sel <- dat_gh %>%
  filter(usb3 == 1,
         usb2 == 1)
dat_sel[varnames_sel]

dat_gh %>% filter(str_detect(Extern, "WLAN 802.11b"))

## ========================================================================= ##
## write out data
## ========================================================================= ##

dat_sel <- dat_gh %>% 
  arrange(desc(price_min))
write_csv(dat_sel, path = "nas-2018-11_full.csv")

dat_sel[varnames_sel] %>% View()


