## ######################################################################### ##
## Wäschetrockner
## ######################################################################### ##

# rm(list = ls(), inherits = TRUE); rstudioapi::restartSession()


#devtools::install_github("ingonader/rgeizhals", build_vignettes = TRUE)

library(rvest)
library(stringr)
library(rgeizhals)
library(dplyr)

options(tibble.width = Inf)

## ========================================================================= ##
## get data from geizhals
## ========================================================================= ##

##load("trockner-2018-10.Rdata")

url_gh <- "https://geizhals.at/?cat=hwaeschtr&xf=1027_W%E4rmepumpentrockner%7E1296_10%7E1747_8%7E7641_40%7E7653_9"
dat_gh <- get_geizhals_data(url_gh)

dat_gh

#save.image("trockner-2018-10.Rdata")

## ========================================================================= ##
## data exploration
## ========================================================================= ##

names(dat_gh)

## get the summary of some of the features:
get_feature_summary(dat_gh, col = "Ausstattung") %>% head(n = 12)
get_feature_summary(dat_gh, col = "Bauart") %>% head(n = 12)
get_feature_summary(dat_gh, col = "Wartungshinweise") %>% head(n = 10)
get_feature_summary(dat_gh, col = "Programme") %>% head(n = 10)
get_feature_summary(dat_gh, col = "Sicherheit") %>% head(n = 10)
get_feature_summary(dat_gh, col = "Kondensationseffizienzklasse") %>% head(n = 10)


## ========================================================================= ##
## add features
## ========================================================================= ##


## add feature indicators:
dat_gh <- dat_gh %>% mutate(
  "kondenswasserablauf_ind" = extract_feature_ind(dat_gh,
                                                  col = "Ausstattung",
                                                  regex = "Kondenswasserablauf"),
  "wartungsfreierkond_ind" = extract_feature_ind(dat_gh,
                                                 col = "Ausstattung",
                                                 regex = "wartungsfreier Kondensator"),
  "wartungshinweis_filter_ind" = extract_feature_ind(dat_gh,
                                                 col = "Wartungshinweise",
                                                 regex = "Filter reinigen"),
  "wartungshinweis_kondensat_ind" = extract_feature_ind(dat_gh,
                                                    col = "Wartungshinweise",
                                                    regex = "Kondensatbehälter leeren"),
  "wartungshinweis_flusensieb_ind" = extract_feature_ind(dat_gh,
                                                    col = "Wartungshinweise",
                                                    regex = "Flusensieb reinigen"),
  "wartungshinweis_waermetauscher_ind" = extract_feature_ind(dat_gh,
                                                    col = "Wartungshinweise",
                                                    regex = "Wärmetauscher"),
  "lautstaerke" = stringr::str_extract(dat_gh[["Geräuschentwicklung"]], "^[0-9]+") %>% as.numeric(),
  "energieverbrauch_num" = stringr::str_extract(dat_gh[["Energieverbrauch"]], "^[0-9]+") %>% as.numeric()
)

#dat_gh[["lautstaerke"]] %>% table()

## add number of "wartungshinweise" as feature:
varnames_wartungshinweise <- stringr::str_subset(names(dat_gh), "^wartungshinweis.*_ind$")
dat_gh <- dat_gh %>% mutate(
  "wartungshinweis_cnt" = apply(dat_gh[varnames_wartungshinweise], 1, sum)
)

head(dat_gh)

table(dat_gh$energieverbrauch_num)

## ========================================================================= ##
## filter and inspect data
## ========================================================================= ##

## ------------------------------------------------------------------------- ##
## only with kondenswasserablauf
## ------------------------------------------------------------------------- ##

dat_gh %>% filter(
  kondenswasserablauf_ind == 1,
  Energieeffizienzklasse == "A+++",
  wartungshinweis_cnt >= 3
)

dat_gh %>% filter(prodname == "AEG Electrolux T67680IH3 Wärmepumpentrockner") %>%
  tidyr::gather() %>% 
  View()

dat_gh %>% filter(prodname == "AEG Electrolux T7768VIH Wärmepumpentrockner") %>%
  tidyr::gather() %>% 
  View()
  
dat_gh %>% filter(prodname %in% 
                    c("AEG Electrolux T67680IH3 Wärmepumpentrockner",
                      "AEG Electrolux T7768VIH Wärmepumpentrockner")) %>%
  tidyr::gather() %>% 
  View()


## Wartung Wärmetauscher: Miele bietet absaugbaren Schwamm;
## Siemens und Bosch: Wartungsfreie Wärmetauscher

## Konsument:
## AEG T9DE87685 (ca. 1000 Euro)
## Miele TWF 500 WP Edition Eco (ca. 1000 Euro)
## Bosch WTWH7540 (ca. 1300 Euro)
## Siemens WT7WH590 (ca. 1300 Euro)

dat_gh %>% filter(str_detect(prodname, "Miele|AEG|Siemens|Bosch")) %>% arrange(prodname)%>% View()

dat_gh %>% filter(str_detect(prodname, "Miele")) %>% arrange(price_min)%>% View()

## ------------------------------------------------------------------------- ##
## only with kondenswasserablauf
## ------------------------------------------------------------------------- ##

table(dat_gh[["energieverbrauch_num"]])

dat_gh %>% filter(
  kondenswasserablauf_ind == 1,
  #Energieeffizienzklasse == "A+++",
  energieverbrauch_num <= 175
) %>% print(n = 20)

dat_gh %>% filter(
  #kondenswasserablauf_ind == 1,
  #Energieeffizienzklasse == "A+++",
  energieverbrauch_num <= 175
) %>% print(n = 20)

## ========================================================================= ##
## save data to disk
## ========================================================================= ##

readr::write_csv(dat_gh, path = "trockner-2018-10.csv")

## [[to do]]
## * check Wartungsaufwand (!)
