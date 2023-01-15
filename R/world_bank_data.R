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
               "CIV", "KEN", "MAR", "SEN", "ZAF",
               "BGD", "IND", "IDN", "PAK", "PHL", "LKA", 
               "HKG", "JPN", "KOR", "MYS", "SGP", "THA")

kowcon <- world_bank_consumption%>%filter(Country_Code %in% countries)
PCE <- read_csv("GoogleDrive/Datasets/PCE.csv")
PCE<- PCE %>% mutate(PCE = PCE*(10^9))
japan_capformation <- read_csv("GoogleDrive/Datasets/japan_capformation.csv")



PCE_annual <- PCE[seq(12,nrow(PCE), 12),]


logkow <- log(kowcon[,3:64])
logkow <- cbind(kowcon[,1:2], logkow)
difflogkow <- logkow[, 4:64] - logkow[,3:63]
cons_growth <- cbind(kowcon[,1:2], difflogkow)

world_bank_gdp <- read_csv("GoogleDrive/Datasets/world_bank_gdp.csv")

kowgdp <- world_bank_gdp%>%filter(Country_Code %in% countries)


logkow <- log(kowgdp[,3:64])
logkow <- cbind(kowgdp[,1:2], logkow)
difflogkow <- logkow[, 4:64] - logkow[,3:63]
gdp_growth <- cbind(kowgdp[,1:2], difflogkow)

world_bank_capital <- read_csv("GoogleDrive/Datasets/capital_formation_wb.csv")
nz_capital_formation <- read_csv("GoogleDrive/Datasets/capital_formation_fred.csv")
nz_capital_formation<-nz_capital_formation[seq(4,141,4),]
nz_capital_formation <- nz_capital_formation[1:34,]
usa_capital_formation <- read_csv("GoogleDrive/Datasets/usa_capital_formation.csv")
japan_capformation <- read_csv("GoogleDrive/Datasets/japan_capformation.csv")

world_bank_capital[world_bank_capital$Country_Name=="New Zealand", 31:64] = t(nz_capital_formation$NZLGFCFQDSMEI)
world_bank_capital[world_bank_capital$Country_Name=="United States", 3:64] = t(usa_capital_formation$USAGFCFADSMEI)
world_bank_capital[world_bank_capital$Country_Name=="Japan", 37:64] = t(japan_capformation$JPNGFCFADSMEI)

world_bank_capital[252,63:64]
kowcap <- world_bank_capital%>%filter(Country_Code %in% countries)
logkow <- log(kowcap[,3:64])
logkow <- cbind(kowcap[,1:2], logkow)
difflogkow <- logkow[, 4:64] - logkow[,3:63]
cap_growth <- cbind(kowcap[,1:2], difflogkow)

newdata <- list()
for(i in 1:nrow(cap_growth)){
  newdata[[i]] <- rbind(gdp_growth[i,], cons_growth[i,], cap_growth[i,])
}

newdata <- do.call(rbind, newdata)

colnms <- list() 
for(i in 1:nrow(newdata)){
  if(i%%3 == 1){
    colnms[[i]] <- paste("rgdpna",newdata[i,'Country_Code'], sep='')
  }
  if(i%%3 == 2){
    colnms[[i]] <- paste("rconna",newdata[i, 'Country_Code'], sep='')
  }
  if(i%%3 == 0){
    colnms[[i]] <- paste("rcap",newdata[i, 'Country_Code'], sep='')
    
  }
}

newdata <- data.frame(cbind(colnames=unlist(colnms), newdata))
newdata <- newdata[,-c(2,3)]

cname <- newdata$colnames
newdata <- as.data.frame(t(newdata[,-1]))
colnames(newdata) <- cname

rownames(newdata) <- NULL

year <- 1961:2021
newdata <- as.data.frame(cbind(year, newdata))

newdata <- newdata[,c('year', 'rgdpnaUSA', 'rconnaUSA', 'rcapUSA',
  'rgdpnaCAN', 'rconnaCAN', 'rcapCAN',
  'rgdpnaMEX', 'rconnaMEX', 'rcapMEX',
  'rgdpnaAUS', 'rconnaAUS', 'rcapAUS',
  'rgdpnaNZL', 'rconnaNZL', 'rcapNZL',
  'rgdpnaCRI', 'rconnaCRI', 'rcapCRI',
  'rgdpnaDOM', 'rconnaDOM', 'rcapDOM',
  'rgdpnaSLV', 'rconnaSLV', 'rcapSLV',
  'rgdpnaGTM', 'rconnaGTM', 'rcapGTM',
  'rgdpnaHND', 'rconnaHND', 'rcapHND',
  'rgdpnaJAM', 'rconnaJAM', 'rcapJAM',
  'rgdpnaPAN', 'rconnaPAN', 'rcapPAN',
  #'rgdpnaTTO', 'rconnaTTO', 'rcapTTO',
  'rgdpnaARG', 'rconnaARG', 'rcapARG',
  'rgdpnaBOL', 'rconnaBOL', 'rcapBOL',
  'rgdpnaBRA', 'rconnaBRA', 'rcapBRA',
  'rgdpnaCHL', 'rconnaCHL', 'rcapCHL',
  'rgdpnaCOL', 'rconnaCOL', 'rcapCOL',
  'rgdpnaECU', 'rconnaECU', 'rcapECU',
  'rgdpnaPRY', 'rconnaPRY', 'rcapPRY',
  'rgdpnaPER', 'rconnaPER', 'rcapPER',
  'rgdpnaURY', 'rconnaURY', 'rcapURY',
  #'rgdpnaVEN', 'rconnaVEN', 'rcapVEN',
  'rgdpnaFRA', 'rconnaFRA', 'rcapFRA',
  'rgdpnaAUT', 'rconnaAUT', 'rcapAUT',
  'rgdpnaBEL', 'rconnaBEL', 'rcapBEL',
  'rgdpnaDNK', 'rconnaDNK', 'rcapDNK',
  'rgdpnaFIN', 'rconnaFIN', 'rcapFIN',
  'rgdpnaDEU', 'rconnaDEU', 'rcapDEU',
  'rgdpnaGRC', 'rconnaGRC', 'rcapGRC',
  'rgdpnaISL', 'rconnaISL', 'rcapISL',
  'rgdpnaIRL', 'rconnaIRL', 'rcapIRL',
  'rgdpnaITA', 'rconnaITA', 'rcapITA',
  'rgdpnaLUX', 'rconnaLUX', 'rcapLUX',
  'rgdpnaNLD', 'rconnaNLD', 'rcapNLD',
  'rgdpnaNOR', 'rconnaNOR', 'rcapNOR',
  'rgdpnaPRT', 'rconnaPRT', 'rcapPRT',
  'rgdpnaESP', 'rconnaESP', 'rcapESP',
  'rgdpnaSWE', 'rconnaSWE', 'rcapSWE',
  'rgdpnaCHE', 'rconnaCHE', 'rcapCHE',
  'rgdpnaGBR', 'rconnaGBR', 'rcapGBR',
  'rgdpnaCMR', 'rconnaCMR', 'rcapCMR',
  'rgdpnaCIV', 'rconnaCIV', 'rcapCIV',
  'rgdpnaKEN', 'rconnaKEN', 'rcapKEN',
  'rgdpnaMAR', 'rconnaMAR', 'rcapMAR',
  'rgdpnaSEN', 'rconnaSEN', 'rcapSEN',
  'rgdpnaZAF', 'rconnaZAF', 'rcapZAF',
  #'rgdpnaZWE', 'rconnaZWE', 'rcapZWE',
  'rgdpnaBGD', 'rconnaBGD', 'rcapBGD',
  'rgdpnaIND', 'rconnaIND', 'rcapIND',
  'rgdpnaIDN', 'rconnaIDN', 'rcapIDN',
  'rgdpnaPAK', 'rconnaPAK', 'rcapPAK',
  'rgdpnaPHL', 'rconnaPHL', 'rcapPHL',
  'rgdpnaLKA', 'rconnaLKA', 'rcapLKA',
  'rgdpnaHKG', 'rconnaHKG', 'rcapHKG',
  'rgdpnaJPN', 'rconnaJPN', 'rcapJPN',
  'rgdpnaKOR', 'rconnaKOR', 'rcapKOR',
  'rgdpnaMYS', 'rconnaMYS', 'rcapMYS',
  'rgdpnaSGP', 'rconnaSGP', 'rcapSGP',
  'rgdpnaTHA', 'rconnaTHA', 'rcapTHA')]


K <- 171
N <- 60
newkow <- rbind(KOWlfd, newdata[60:61,2:172])
row.names(newkow) <- NULL
codePath <- '~/CodeProjects/CProjects/build/'
dataPath <- '~/GoogleDrive/Datasets/'


data <- cbind(year=1961:2021, newkow)

yt <- t(newkow)

write.table(row.names(yt), paste(dataPath, "country_index.csv", sep=""))
ncountries <- K/3
Xt <- matrix(0, nrow=K*N, ncol=3)
ones <-matrix(1, nrow=3, ncol=1)

# Predict for time t = 1 to time N-1 for Xt
for(t in 1:(N))
{
  for (j in 1:ncountries)
  {
    w <- (1:3) + ((j-1)*3)
    
    q <- w + (t-1)*K
    
    Xt[q,] <- kronecker(ones, t(yt[w,t]))
  }
}

Xt <- cbind(rep(1,nrow(Xt)),Xt)
Xtkow <- rep(1,nrow(Xt))
yt <- yt[,2:61]
yt <- (yt - mean(yt))/sd(yt)
write.table(newkow, paste(codePath, 'newkow.csv', sep=''), row.names = TRUE, col.names=TRUE, sep=",")
write.table(yt, paste(codePath, 'yt.csv', sep=''), row.names = FALSE, col.names=FALSE, sep=",")
write.table(Xt, paste(codePath, 'Xt.csv', sep=''), row.names = FALSE, col.names=FALSE, sep=",")
write.table(Xtkow, paste(codePath, 'Xtbaseline.csv', sep=''), row.names = FALSE, col.names=FALSE, sep=",")

N <- ncol(yt)
K <- nrow(yt)

years <- 1980:1990
for (y in 1:10)
{
  ending <- yt[,1:(19+y)]

  beginning <- yt[,(19+y+1):N]
  begnameyt <- sprintf("yt_%d_beg.csv",years[y]+1)
  endnameyt <- sprintf("yt_%d_end.csv",years[y])
  begnameXt <- sprintf("Xt_%d_beg.csv",years[y]+1)
  endnameXt <- sprintf("Xt_%d_end.csv",years[y])
  Xtbeg <- matrix(0, nrow=K*(ncol(beginning)-1), ncol=4)
  Xtend <- matrix(0, nrow=K*(ncol(ending)-1), ncol=4)
  for(t in 1:(ncol(beginning)-1))
  {
    for (j in 1:ncountries)
    {
      w <- (1:3) + ((j-1)*3)
      q <- w + (t-1)*K
      Xtbeg[q,] <- kronecker(ones, cbind(1,t(beginning[w,t])))
    }
  }
  
  for(t in 1:(ncol(ending)-1))
  {
    for (j in 1:ncountries)
    {
      w <- (1:3) + ((j-1)*3)
      q <- w + ( (t-1)*K )
      Xtend[q, ] = kronecker(ones, cbind(1,t(ending[w, t])))
    }
  }
  beg <- beginning[,2:ncol(beginning)]
  end <- ending[,2:ncol(ending)]
  write.table(beg, paste(paste(codePath, "timebreaks/", sep=''), begnameyt,sep=''),
              row.names=FALSE,col.names=FALSE,sep=",")
  write.table(Xtbeg, paste(paste(codePath, "timebreaks/", sep=''), begnameXt,sep=''),
              row.names=FALSE,col.names=FALSE,sep=",")
  write.table(end, paste(paste(codePath, "timebreaks/", sep=''), endnameyt,sep=''),
              row.names=FALSE,col.names=FALSE,sep=",")
  write.table(Xtend, paste(paste(codePath, "timebreaks/", sep=''), endnameXt,sep=''),
              row.names=FALSE,col.names=FALSE,sep=",")
}

mean(as.numeric(newdata[61,1+seq(1,ncol(newdata)-1, 3)]))
