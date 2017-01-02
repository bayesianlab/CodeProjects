# source('~/R/Rprojects/finalproject/finalproject_functions.R')


source('~/Coding/R/Rprojects/finalproject/HAL/finalproject_functions.R')

# imputation code

# setwd("C:/Users/64063/Documents/R/Rprojects/finalproject/project_data/")
setwd("~/Coding/R/Rprojects/finalproject/project_data")
# Original unaltered dataset, keep as is and copy
DONT_TOUCH_THIS <- readRDS("keep_pristine.rds")

# latitude and longitude data for all countries in dataset
latlon <- readRDS("latlon.rds")

# Every observation with their latitude and longitude column binded
datWlatlon <- readRDS("dataWlatlon.rds")
# This guy is bad
datWlatlon <- datWlatlon[-5015,]

# Cleaned data (missings out)
finaldat <- getData(DONT_TOUCH_THIS)

# USA zipcode data with latitude and longitude 
zipcode <- readRDS("zipcode.RDS")

# USA specifically, with latitude and longitude data attached. Function below will
# generate it from finaldat, but takes long time. 
uspeepswithLL <- readRDS("uspeepswithLL.rds")
uspeepswithLL <- finaldat[finaldat$NATIONALITY == "UNITED STATES",]
uspeepswithLL <- uspeepswithLL[!is.na(uspeepswithLL$STATE),]
uspeepswithLL <- uspeepswithLL[!is.na(uspeepswithLL$STATE),]
uspeepswithLL <- uspeepswithLL[!uspeepswithLL$STATE=="", ]
uspeepswithLL$STATE <- factor(uspeepswithLL$STATE)
# uspeepswithLL <- getLatLonUSAPeeps(finaldat)

# State zip codes
state_zcodes <- readRDS("state_zcodes.rds")
state_zcodes[,1] <- as.character(state_zcodes[,1])
state_zcodes[,2] <- as.character(state_zcodes[,2])
cNames <- c("region", "STATE_CODE", "Latitude", "Longitude")
colnames(state_zcodes) <- cNames
state_zcodes$region <- tolower(state_zcodes$region)

# Lat Lon by state for us obs only
stateLatLon <- readRDS("stateLatLon.rds")
stateLatLon$region <- as.character(stateLatLon$region)
sumStates <- as.data.frame(table(stateLatLon$region), stringsAsFactors = FALSE)
cNames <- c("region", "freq")
colnames(sumStates) <- cNames
# This code can regenerate it. Some manipulations may need to be made (get rid of factors, and lower
# case the region).
# stateLatLon <- getStateLatLon(uspeepswithLL, state_zcodes)
# stateLatLon$Longitude <- as.numeric(as.character(stateLatLon$Longitude))
# stateLatLon$Latitude <- as.numeric(as.character(stateLatLon$Latitude))

# Load map data which includes information for state polygons
states <- map_data("state")

# Frequency by state with lat and lon information joined
freqState <- inner_join(states, sumStates, by="region")
freqState <- merge(state_zcodes, freqState, by="region")

# Complete data set has imputed data

completeData <- readRDS("completedat.rds")


# group only important countries together
cdNation <- finaldat

unneeedCountries <- c(  
  "","ALBANIA","ANTIGUA AND BARBUDA","ARGENTINA","AUSTRIA",
  "BAHAMAS","BARBADOS","BELARUS",
  "BELGIUM","BELIZE","BERMUDA",
  "BOLIVIA","BOSNIA AND HERZEGOVINA","BRAZIL",
  "BULGARIA","CAYMAN ISLANDS",
  "CHILE","CHINA","COLOMBIA",
  "COSTA RICA","CROATIA (Hrvatska)","CUBA",
  "CYPRUS","CZECH REPUBLIC","DENMARK",
  "DOMINICA","DOMINICAN REPUBLIC","ECUADOR",
  "EGYPT","EL SALVADOR","ESTONIA",
  "ETHIOPIA","FINLAND","FRANCE",
  "GEORGIA","GERMANY (Deutschland)","GHANA","GREECE","GUATEMALA",
  "HONDURAS","HONG KONG (Special Administrative Region of China)","HUNGARY",
  "ICELAND","INDIA","INDONESIA",
  "IRAN (Islamic Republic of Iran)","IRELAND","ISRAEL",
  "ITALY","JAMAICA","JAPAN",
  "JORDAN (Hashemite Kingdom of Jordan)","KAZAKHSTAN","KENYA",
  "KOREA Republic of South Korea","KUWAIT","KYRGYZSTAN",
  "LATVIA","LEBANON","LITHUANIA",
  "LUXEMBOURG","MALAYSIA","MALTA",
  "MEXICO","MICRONESIA (Federated States of Micronesia)","MOLDOVA",
  "NAMIBIA","NEPAL","NETHERLANDS ANTILLES","NEW ZEALAND","NIGERIA",
  "NORWAY","OMAN","PAKISTAN",
  "PALAU","PANAMA","PARAGUAY",
  "PERU","PHILIPPINES","POLAND",
  "PORTUGAL","ROMANIA","RUSSIAN FEDERATION",
  "SAINT LUCIA","SAINT VINCENT AND THE GRENADINES","SAUDI ARABIA (Kingdom of Saudi Arabia)",
  "SERBIA (Republic of Serbia)","SINGAPORE","SLOVAKIA (Slovak Republic)",
  "SLOVENIA","SOUTH AFRICA (Zuid Afrika)","SPAIN (Espa\xf1a)",
  "SRI LANKA (formerly Ceylon)","SURINAME","SWEDEN",
  "SWITZERLAND (Confederation of Helvetia)","SYRIAN ARAB REPUBLIC","TAIWAN (Chinese Taipei for IOC)",
  "THAILAND","TRINIDAD AND TOBAGO","TURKEY",
  "UGANDA","UKRAINE",
  "URUGUAY","VENEZUELA","VIET NAM", "ZIMBABWE"
  )
levels(cdNation$PAX_LOYALTY)
cdNation$PAX_LOYALTY <- mapvalues(cdNation$PAX_LOYALTY, from= c("0S", "1S    ", "2S    ", "3S    ",
                                                                "4S    ", "5S    ",  "P1    "),
                                  to = c("0Star", "1Star", "2Star", "3Star", "4Star", "5Star", "P1"))
cdNation$PAX_LOYALTY <- combineLevels(cdNation$PAX_LOYALTY,
                                      c("1N    ", "288925449", "NH    ", "P1", "FT    ", ""),
                                      newLabel=c("Other"))

table(cdNation$PAX_LOYALTY)

cdNation$NATIONALITY <- combineLevels(finaldat$NATIONALITY, unneeedCountries, "Other")
cdNation <- cdNation[!is.na(cdNation$INCOME), ]
dailyBar <- cdNation$BAR_REV / as.numeric(as.character(cdNation$CRUISELENGTH))
dailyPhoto <- cdNation$PHOTO_REV / as.numeric(as.character(cdNation$CRUISELENGTH))
dailySpa <- cdNation$SPA_REV / as.numeric(as.character(cdNation$CRUISELENGTH))
dailyShorex <- cdNation$SHOREX_REV / as.numeric(as.character(cdNation$CRUISELENGTH))
dailyMisc <- cdNation$MISC_REV / as.numeric(as.character(cdNation$CRUISELENGTH))
dailyComm <- cdNation$COMM_REV / as.numeric(as.character(cdNation$CRUISELENGTH))
dailyRetail <- cdNation$RETAIL_REV / as.numeric(as.character(cdNation$CRUISELENGTH))
dailyCasino <- cdNation$CASINO_REV / as.numeric(as.character(cdNation$CRUISELENGTH))
cdNation <- cbind(dailyBar,dailyPhoto, dailySpa, dailyShorex, dailyMisc, dailyComm, dailyRetail, dailyCasino, cdNation)

cdNation$CRUISELENGTH <- factor(cdNation$CRUISELENGTH)


cdNation$CRUISELENGTH <- combineLevels(cdNation$CRUISELENGTH, c("3", "7", "8", "9"), 
                                   newLabel =c("3-9"))
cdNation$CRUISELENGTH <- combineLevels(cdNation$CRUISELENGTH, c("10", "11","12", "13", "14", "15", "16", "17"), 
                                   newLabel = c("10-17"))
cdNation$CRUISELENGTH <- combineLevels(cdNation$CRUISELENGTH, c("18", "19", "20", "22", "26", "32", "35", "42", 
                                                                 "47", "49", "50", "78", "115", "116"), 
                                       newLabel = c("18-116"))
table(cdNation$CRUISELENGTH)
cdNation <- cdNation[!is.na(cdNation$EGSS_OVERALL), ]
#cdNation <- cdNation[!is.na(cdNation$EGSS_OVERALL), ]

# Not doing this anymore
# threeDay <- cdNation[cdNation$CRUISELENGTH == "3", ]
# sevenDay <- cdNation[cdNation$CRUISELENGTH == "7", ]
# twelveDay <- cdNation[cdNation$CRUISELENGTH == "12", ]
# fourteenDay <- cdNation[cdNation$CRUISELENGTH == "14", ]
# twentysixDay <- cdNation[cdNation$CRUISELENGTH == "26", ]
# onehundredsixteenDay <- cdNation[cdNation$CRUISELENGTH == "116", ]
# table(cdNation$CRUISELENGTH)

# completeData <- cbind(finaldat$totalSpent, finaldat$onBoardDailySpend, completeData)

# latlonCodes <- getGeocodes(finaldat)
# missingCountryLatLon <- getMissingLatLonCoors()
# latlonCodes <- fillMissingData(latlonCodes, missingCountryLatLon)
