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

##load("cellphone-2018-11.Rdata")

## Geizhals:
## Cell phones without contract:
## https://geizhals.at/?cat=umtsover
## all phones from Huawei, LG, Samsung, Sony, Xiaomi
## (for comparing with free offers from cell phone provider)

url_gh <- "https://geizhals.at/?cat=umtsover&xf=1022_Huawei~1022_LG~1022_Samsung~1022_Sony~1022_Xiaomi~148_Android&asuch=&bpmin=&bpmax=&v=e&hloc=at&filter=aktualisieren&plz=&dist=&mail=&sort=p&bl1_id=30"

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
## step 1: get listpage data
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##

## get data: all list pages, but only details for 10 devices: 
dat_gh_all <- get_geizhals_data(url_gh, max_items = 3, max_pages = Inf)

dat_gh_all

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
## step 2: get specific detailpages
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##

## identify cell phones for comparison:
pattern <- c("p20 lite",
             "q7 plus", 
             "galaxy s7 g930f",
             "galaxy a[67][^+]*duos", 
             "galaxy j6[^+]*duos", 
             "xcover 4",
             "xz1 [^(Compact)]",
             "Redmi 5 [^(Plus)]") %>% 
  paste(collapse = "|")
wch_phone <- grepl(pattern, dat_gh_all[["prodname"]], ignore.case = TRUE)
dat_gh_all[wch_phone, "prodname"] %>% pull()

## get corresponding urls:
wch_url <- dat_gh_all[wch_phone, "detailpage_url"] %>% pull()

## get html for these urls and parse it::
detailpagehtml_list <- fetch_all_detailpage_html(wch_url)
dat_detailpage <- parse_all_detailpages(detailpagehtml_list)

head(dat_listpage)
head(dat_detailpage)


## fake listpage:
dat_listpage <- dat_gh_all[, 1:6]
## [[todo]]

## join listpage data to detailpage data:
dat_gh <- join_details_to_listpage(dat_listpage,
                                   dat_detailpage)
dat_gh <- dat_gh %>% filter(detailpage_url %in% wch_url)
dat_gh

#save.image("cellphone-2018-11.Rdata")



## ========================================================================= ##
## data exploration
## ========================================================================= ##

names(dat_gh)
table(dat_gh[["Akku"]])
get_feature_summary(dat_gh, "Sensoren")
get_feature_summary(dat_gh, "Besonderheiten")
get_feature_summary(dat_gh, "Navigation")
get_feature_summary(dat_gh, "Schnittstellen")

extract_feature_ind(dat_gh, col = "Schnittstellen", regex = "Bluetooth")
extract_feature_ind(dat_gh, col = "Display", regex = "Gorilla")


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

## Gorilla glass:
dat_gh[["gorilla"]] <- extract_feature_ind(dat_gh, col = "Display", regex = "Gorilla")

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
  #"Gelistet seit", 
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
  "ipx",
  "gorilla"
)

dat_sel <- dat_gh %>% 
  filter(akku_kapazitaet >= 2500,
         glonass == 1,
         listprice <= 300)

## ========================================================================= ##
## write out data
## ========================================================================= ##

dat_sel <- dat_gh %>% 
  arrange(desc(price_min))
#dat_sel %>% print(n = 30)
write_csv(dat_sel, path = "cellpone-2018-11_full.csv")

dat_sel <- dat_gh[varnames_sel] %>% 
  arrange(desc(price_min))
write_csv(dat_sel, path = "cellpone-2018-11_red.csv")

dat_sel[varnames_sel] %>% View()


