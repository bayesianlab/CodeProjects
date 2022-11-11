library(readr)
library(tidyverse)
library(data.table)
world_bank_consumption <- read_csv("GoogleDrive/Datasets/world_bank_consumption.csv")

countries <- c("USA", "CAN", "MEX", "AUS", "NZL", "CRI",
               "DOM", "SLV", "GTM", "HND", "JAM", "PAN", 
                "ARG", "BOL", "BRA", "CHL", "COL",
               "ECU", "PRY", "PER", "URY", "FRA",
               "AUT", "BEL", "DNK", "FIN", "DEU", "GRC",
               "ISL", "IRL", "ITA", "LUX", "NLD", "NOR",
               "PRT", "ESP", "SWE", "CHE", "GBR", "CMR",
               "CIV", "KEN", "MAR", "SEN", "ZAF", "ZWE",
               "BGD", "IND", "IDN", "PAK", "PHL", "LKA", 
               "HKG", "JPN", "KOR", "MYS", "SGP", "THA")

kowcon <- world_bank_consumption%>%filter(Country_Code %in% countries)


logkow <- log(kow[,3:64])
logkow <- cbind(kow[,1:2], logkow)
difflogkow <- logkow[, 4:64] - logkow[,3:63]
cons_growth <- cbind(kow[,1:2], difflogkow)

world_bank_gdp <- read_csv("GoogleDrive/Datasets/world_bank_imf_gdp.csv")

kowgdp <- world_bank_gdp%>%filter(Country_Code %in% countries)

logkow <- log(kowgdp[,3:64])
logkow <- cbind(kowgdp[,1:2], logkow)
difflogkow <- logkow[, 4:64] - logkow[,3:63]
gdp_growth <- cbind(kowgdp[,1:2], difflogkow)

world_bank_capital <- read_csv("GoogleDrive/Datasets/world_bank_capital.csv")
kowcap <- world_bank_capital%>%filter(Country_Code %in% countries)
logkow <- log(kowcap[,3:64])
logkow <- cbind(kowcap[,1:2], logkow)
difflogkow <- logkow[, 4:64] - logkow[,3:63]
cap_growth <- cbind(kowcap[,1:2], difflogkow)

