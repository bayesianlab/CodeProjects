# source('~/R/Rprojects/finalproject/finalproject_functions.R')
homeD <- '/Users/dillonflannery-valadez/Coding/R/Rprojects/finalproject/project_data/'
library(ggplot2)
library(VIM)
library(mice)
library(MCMCpack)
library(BMS)
library(ggplot2)
library(maps)
library(ggmap)
library(zipcode)
library(RCurl)
library(plyr)
library(maptools)
library(rgdal)
library(devtools)
library(dplyr)
library(rockchalk)
library(BLR)
library(BayesFactor)
library(base)
library(bayesm)
library(lme4)
library(lmtest)
library(car)
library(caret)
library(dummies)
library(date)
library(reshape2)
library(forecast)
library(tseries)
library(scales)
source('~/Coding/R/Rprojects/finalproject/HAL/finalproject_functions.R')

fulldataset <- readRDS("~/Coding/R/Rprojects/finalproject/project_data/newDataset.rds")
fulldataset$NTR <- as.numeric(as.character(fulldataset$NTR))
fulldataset <- fulldataset[!is.na(fulldataset$NTR), ]
fulldataset <- fulldataset[fulldataset$NTR >0 ,]
fulldataset$TRADE <- factor(fulldataset$TRADE)
fulldataset$CRUISE_END_DATE <- factor(fulldataset$CRUISE_END_DATE)
fulldataset$SHIPNAME <- factor(fulldataset$SHIPNAME)
fulldataset$SHIPCLASSDESC <- factor(fulldataset$SHIPCLASSDESC)
fulldataset <- fulldataset[fulldataset$PAX_GENDER != "", ]
fulldataset$PAX_GENDER <- factor(fulldataset$PAX_GENDER)
fulldataset <- fulldataset[fulldataset$X_META != "", ]
fulldataset$BAR_REV <- as.numeric(as.character(fulldataset$BAR_REV))
fulldataset$PHOTO_REV<- as.numeric(as.character(fulldataset$PHOTO_REV))
fulldataset <- fulldataset[fulldataset$PAX_MARINER_NO != "", ]
fulldataset <- fulldataset[fulldataset$PAX_MARINER_NO != "0", ]
fulldataset <- fulldataset[fulldataset$PAX_LOYALTY != "", ]
fulldataset$PAX_LOYALTY <- factor(fulldataset$PAX_LOYALTY)
table(fulldataset$SHIPNAME)
fulldataset$SHIPNAME <- factor(fulldataset$SHIPNAME)
unneededCountries <- c("ALBANIA")        
fulldataset <- fulldataset[fulldataset$NATIONALITY != "", ]
fulldataset$NATIONALITY <- factor(fulldataset$NATIONALITY)
summary(fulldataset$NATIONALITY)

unneededCountries <- c("AFGHANISTAN",                                        "ALBANIA",                                            "ALGERIA (El Djaza\xefr)",                           
"AMERICAN SAMOA",                                     "ANDORRA",                                            "ANTIGUA AND BARBUDA",                               
"ARGENTINA",                                          "ARMENIA",                                            "AUSTRALIA",                                         
"AUSTRIA",                                            "AZERBAIJAN",                                         "BAHAMAS",                                           
"BAHRAIN",                                            "BANGLADESH",                                         "BARBADOS",                                          
"BELARUS",                                            "BELGIUM",                                            "BELIZE",                                            
"BENIN",                                              "BERMUDA",                                            "BOLIVIA",                                           
"BOSNIA AND HERZEGOVINA",                             "BOTSWANA",                                           "BRAZIL",                                            
"BRUNEI DARUSSALAM",                                  "BULGARIA",                                           "CAMBODIA",                                          
"CAMEROON",                                                                                        "CAYMAN ISLANDS",                                    
"CENTRAL AFRICAN REPUBLIC",                           "CHILE",                                              "CHINA",                                             
"COLOMBIA",                                           "CONGO",                                              "COSTA RICA",                                        
"COTE D IVOIRE (Ivory Coast)",                        "CROATIA (Hrvatska)",                                 "CUBA",                                              
"CYPRUS",                                             "CZECH REPUBLIC",                                     "DENMARK",                                           
"DOMINICA",                                           "DOMINICAN REPUBLIC",                                 "ECUADOR",                                           
"EGYPT",                                             "EL SALVADOR",                                        "ESTONIA",                                           
"ETHIOPIA",                                           "FIJI",                                               "FINLAND",                                           
"FRANCE",                                             "FRENCH POLYNESIA",                                   "GABON",                                             
"GAMBIA",                                             "GEORGIA",                                                                        
"GHANA",                                              "GIBRALTAR",                                    
"GREECE",                                             "GRENADA",                                            "GUADELOUPE",                                        
"GUATEMALA",                                          "GUERNSEY",                                           "GUYANA",                                            
"HAITI",                                              "HONDURAS",                                           "HONG KONG (Special Administrative Region of China)",
"HUNGARY",                                            "ICELAND",                                            "INDIA",                                             
"INDONESIA",                                          "IRAN (Islamic Republic of Iran)",                    "IRAQ",                                              
"IRELAND",                                            "ISLE OF MAN",                                        "ISRAEL",                                            
"ITALY",                                              "JAMAICA",                                            "JAPAN",                                             
"JERSEY",                                             "JORDAN (Hashemite Kingdom of Jordan)",               "KAZAKHSTAN",                                        
"KENYA",                                              "KOREA Democratic Peoples Republic of North Korea",   "KOREA Republic of South Korea",                     
"KUWAIT",                                             "KYRGYZSTAN",                                         "LAO PEOPLE S DEMOCRATIC REPUBLIC",                  
"LATVIA",                                             "LEBANON",                                            "LESOTHO",                                           
"LIBERIA",                                            "LIBYA (Libyan Arab Jamahirya)",                      "LIECHTENSTEIN (F\xfcrstentum Liechtenstein)",       
"LITHUANIA",                                          "LUXEMBOURG",                                         "MACAO (Special Administrative Region of China)",    
"MACEDONIA (Former Yugoslav Republic of Macedonia)",  "MADAGASCAR",                                         "MALAYSIA",                                          
"MALDIVES",                                           "MALI",                                               "MALTA",                                             
"MARSHALL ISLANDS",                                   "MAURITANIA",                                         "MAURITIUS",                                         
"MEXICO",                                             "MICRONESIA (Federated States of Micronesia)",        "MOLDOVA",                                           
"MONACO",                                             "MONGOLIA",                                           "MONTENEGRO",                                        
"MOROCCO",                                            "MOZAMBIQUE (Mo\xe7ambique)",                         "MYANMAR (formerly Burma)",                          
"NAMIBIA",                                            "NEPAL",                                                                                    
"NETHERLANDS ANTILLES",                               "NEW CALEDONIA",                                      "NEW ZEALAND",                                       
"NICARAGUA",                                          "NIGERIA",                                            "NORWAY",                                            
"OMAN",                                               "PAKISTAN",                                           "PALAU",                                             
"PALESTINIAN TERRITORIES",                            "PANAMA",                                             "PAPUA NEW GUINEA",                                  
"PARAGUAY",                                           "PERU",                                               "PHILIPPINES",                                       
"POLAND",                                             "PORTUGAL",                                           "PUERTO RICO",                                       
"QATAR",                                              "ROMANIA",                                            "RUSSIAN FEDERATION",                                
"RWANDA",                                             "SAINT LUCIA",                                        "SAINT VINCENT AND THE GRENADINES",                  
"SAMOA (formerly Western Samoa)",                     "SAN MARINO (Republic of)",                           "SAUDI ARABIA (Kingdom of Saudi Arabia)",            
"SENEGAL",                                            "SERBIA (Republic of Serbia)",                        "SEYCHELLES",                                        
"SIERRA LEONE",                                       "SINGAPORE",                                          "SLOVAKIA (Slovak Republic)",                        
"SLOVENIA",                                           "SOLOMON ISLANDS",                                    "SOUTH AFRICA (Zuid Afrika)",                        
"SPAIN (Espa\xf1a)",                                  "SRI LANKA (formerly Ceylon)",                        "SURINAME",                                          
"SWAZILAND",                                          "SWEDEN",                                             "SWITZERLAND (Confederation of Helvetia)",           
"SYRIAN ARAB REPUBLIC",                               "TAIWAN (Chinese Taipei for IOC)",                    "TAJIKISTAN",                                        
"TANZANIA",                                           "THAILAND",                                           "TOGO",                                              
"TONGA",                                              "TRINIDAD AND TOBAGO",                                "TUNISIA",                                           
"TURKEY",                                             "TURKMENISTAN",                                       "TURKS AND CAICOS ISLANDS",                          
"UGANDA",                                             "UKRAINE",                                            "UNITED ARAB EMIRATES",                              
"URUGUAY",                                            "UZBEKISTAN",                                        
"VENEZUELA",                                          "VIET NAM",                                           "VIRGIN ISLANDS",                                    
"YEMEN (Yemen Arab Republic)",                        "ZAMBIA (formerly Northern Rhodesia)",                "ZIMBABWE" )
fulldataset$NATIONALITY <- combineLevels(fulldataset$NATIONALITY, unneededCountries, "Other")
table(fulldataset$NATIONALITY)
table(fulldataset$PAX_LOYALTY)
fulldataset <- fulldataset[fulldataset$PAX_LOYALTY != "100001114", ]
fulldataset <- fulldataset[fulldataset$PAX_LOYALTY != "104156260", ]
fulldataset <- fulldataset[fulldataset$PAX_LOYALTY != "106675218", ]
fulldataset <- fulldataset[fulldataset$PAX_LOYALTY != "106821598", ]
fulldataset <- fulldataset[fulldataset$PAX_LOYALTY != "107759888", ]
fulldataset <- fulldataset[fulldataset$PAX_LOYALTY != "107904567", ]
fulldataset <- fulldataset[fulldataset$PAX_LOYALTY != "107956765", ]
fulldataset <- fulldataset[fulldataset$PAX_LOYALTY != "108021668", ]
fulldataset <- fulldataset[fulldataset$PAX_LOYALTY != "109397349", ]
fulldataset <- fulldataset[fulldataset$PAX_LOYALTY != " 109816512", ]
# That was taking too long.
badIds <- c("109816512", "111227088", "111227096", "111264651","294643994", "294644000", "296372741","411978893", 
            "420448532", "421496845", "421726233","615586674", "824041442", "SVST  ")
for(i in 1:length(badIds)){
  fulldataset <- fulldataset[fulldataset$PAX_LOYALTY != badIds[i], ]
}
fulldataset$PAX_LOYALTY <- factor(fulldataset$PAX_LOYALTY)
table(fulldataset$PAX_LOYALTY)
fulldataset$PAX_LOYALTY <- combineLevels(fulldataset$PAX_LOYALTY, c("0S", "FT    "), "0S")
table(fulldataset$PAX_LOYALTY)

fulldataset$SHIPCLASSDESC <- factor(fulldataset$SHIPCLASSDESC)

NTR_PCD <- fulldataset$NTR / fulldataset$CRUISELENGTH
fds <- cbind(fulldataset, NTR_PCD)
fds$SHOREX_REV <- naZero(fds$SHOREX_REV)
fds$BAR_REV <- naZero(fds$BAR_REV)
fds$PHOTO_REV <- naZero(fds$PHOTO_REV)
fds$SPA_REV <- naZero(fds$SPA_REV)
fds$MISC_REV <- naZero(fds$MISC_REV)
fds$COMM_REV <- naZero(fds$COMM_REV)
fds$RETAIL_REV <- naZero(fds$RETAIL_REV)
fds$CASINO_REV <- naZero(fds$CASINO_REV)
dailyBar <- fds$BAR_REV / fds$CRUISELENGTH
dailyPhoto <- fds$PHOTO_REV / fds$CRUISELENGTH
dailySpa <- fds$SPA_REV / fds$CRUISELENGTH
dailyShorex <- fds$SHOREX_REV / fds$CRUISELENGTH
dailyMisc <- fds$MISC_REV / fds$CRUISELENGTH
dailyComm <- fds$COMM_REV / fds$CRUISELENGTH
dailyRetail <- fds$RETAIL_REV / fds$CRUISELENGTH
dailyCasino <- fds$CASINO_REV / fds$CRUISELENGTH
dailys <- cbind(dailyBar, dailyPhoto, dailySpa, dailyShorex, dailyMisc, dailyComm, 
                dailyRetail, dailyCasino)
dailys <- naZero(dailys)
fds<- cbind( dailys, fds)

x <- as.character(fds$BKNG_OPEN_DATE)
x2 <- as.character(fds$CRUISE_START_DATE)
d <- as.Date(x, format = "%m/%d/%Y")
d2 <- as.Date(x2, format = "%m/%d/%Y")

fds$BKNG_OPEN_DATE <- d
fds$CRUISE_START_DATE <- d2
d3 <- as.numeric(d2 - d)

fds <- cbind(fds, d3)
colnames(fds)[46] <- "BOOK_TO_CRUISE_TIME_DIFF"

fds <- fds[fds$dailyBar >= 0,  ]
fds <- fds[fds$dailyPhoto >= 0,  ]
fds <- fds[fds$dailySpa >= 0,  ]
fds <- fds[fds$dailyShorex >= 0,  ]
fds <- fds[fds$dailyMisc >= 0,  ]
fds <- fds[fds$dailyComm >= 0,  ]
fds <- fds[fds$dailyRetail >= 0,  ]
fds <- fds[fds$dailyCasino >= 0,  ]

levels(fds$INCOME)
table(fds$INCOME)
fds$INCOME <- combineLevels(fds$INCOME, c("", "Prefer not to say"), "NA")
fds$INCOME <- factor(fds$INCOME)



fds <- fds[fds$VOYAGE_CD != "", ]
fds$VOYAGE_CD <- factor(fds$VOYAGE_CD)
table(fds$VOYAGE_CD)

shipDummies <- dummy(fds$SHIPNAME)[,-1]
tradeDummies <- dummy(fds$TRADE)[,-1]
cruiselengthDummies <- dummy(fds$CRUISELENGTH)[,-1]
nationalityDummies <- dummy(fds$NATIONALITY)[,-1]
xMetaDummies <- dummy(fds$X_META)[,-1]
loyaltyDummies <- dummy(fds$PAX_LOYALTY)[,-1]
genderDummies <- dummy(fds$PAX_GENDER)[,-1]

# shorexF <- dailyShorex ~ NTR_PCD + PAX_AGE  + BOOK_TO_CRUISE_TIME_DIFF  + CRUISELENGTH +
#   SHIPNAME + TRADE + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER
predictionData <- cbind(rep(1, nrow(fds)), fds$NTR_PCD, fds$PAX_AGE, fds$BOOK_TO_CRUISE_TIME_DIFF,
                        fds$CRUISELENGTH, shipDummies, tradeDummies, nationalityDummies,
                        xMetaDummies, loyaltyDummies, genderDummies)
dim(predictionData)

shipDummies <- dummy(fds$SHIPNAME)[,-1]
tradeDummies <- dummy(fds$TRADE)[,-1]
cruiselengthDummies <- dummy(fds$CRUISELENGTH)[,-1]
nationalityDummies <- dummy(fds$NATIONALITY)[,-1]
xMetaDummies <- dummy(fds$X_META)[,-1]
loyaltyDummies <- dummy(fds$PAX_LOYALTY)[,-1]
genderDummies <- dummy(fds$PAX_GENDER)[,-1]
predictionDataH <- cbind(rep(1, nrow(fds)), fds$NTR_PCD, fds$PAX_AGE, fds$BOOK_TO_CRUISE_TIME_DIFF, 
                         fds$CRUISELENGTH, shipDummies, nationalityDummies, xMetaDummies, 
                         loyaltyDummies, genderDummies)


fds <- fds[fds$PAX_LOYALTY != "P1    ", ]
# saveRDS(fds, file=paste(homeD,'fds.rds', sep=''))
# saveRDS(predictionDataH, "~/Coding/R/Rprojects/finalproject/project_data/hierarchicalMat.rds")
# saveRDS(fds, "Coding/R/Rprojects/finalproject/project_data/fds.rds")
# saveRDS(predictionData, "Coding/R/Rprojects/finalproject/project_data/predictionData.rds")
