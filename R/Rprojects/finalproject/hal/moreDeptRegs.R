source('~/Coding/R/Rprojects/finalproject/finalproject_functions.R')
fds <- readRDS("~/Coding/R/Rprojects/finalproject/project_data/fds.rds")
predictionData<-readRDS("~/Coding/R/Rprojects/finalproject/project_data/predictionData.rds")


barF <- dailyBar ~ NTR_PCD + PAX_AGE  + BOOK_TO_CRUISE_TIME_DIFF + CRUISELENGTH +
  SHIPNAME + TRADE + NATIONALITY + X_META + PAX_LOYALTY  + PAX_GENDER
barlm <- lm(barF, data= fds)

photoF <- dailyPhoto ~ NTR_PCD + PAX_AGE  + BOOK_TO_CRUISE_TIME_DIFF  + CRUISELENGTH +
  SHIPNAME + TRADE + NATIONALITY + X_META + PAX_LOYALTY  + PAX_GENDER
photolm <- lm(photoF, data=fds)

spaF <- dailySpa ~ NTR_PCD + PAX_AGE  + BOOK_TO_CRUISE_TIME_DIFF + CRUISELENGTH +
  SHIPNAME + TRADE + NATIONALITY + X_META + 
  PAX_LOYALTY    + PAX_GENDER
spalm <- lm(spaF, data=fds)

shorexF <- dailyShorex ~ NTR_PCD + PAX_AGE  + BOOK_TO_CRUISE_TIME_DIFF  + CRUISELENGTH +
  SHIPNAME + TRADE + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER
shorexlm <- lm(shorexF, data= fds)

miscF <- dailyMisc ~ NTR_PCD + PAX_AGE  + BOOK_TO_CRUISE_TIME_DIFF + CRUISELENGTH +
  SHIPNAME + TRADE + NATIONALITY + X_META +  PAX_LOYALTY  + PAX_GENDER
misclm <- lm(miscF, data= fds)

commF <- dailyComm ~ NTR_PCD + PAX_AGE  + BOOK_TO_CRUISE_TIME_DIFF + CRUISELENGTH +
  SHIPNAME + TRADE + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER
commlm <- lm(miscF, data= fds)

retailF <- dailyRetail ~ NTR_PCD + PAX_AGE  + BOOK_TO_CRUISE_TIME_DIFF + CRUISELENGTH +
  SHIPNAME + TRADE + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER
retaillm <- lm(retailF, data= fds)

casinoF <- dailyCasino ~ NTR_PCD + PAX_AGE  + BOOK_TO_CRUISE_TIME_DIFF + CRUISELENGTH +
  SHIPNAME + TRADE + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER
casinolm <- lm(casinoF, data= fds)

sd(fds$dailyBar)
sd(fds$dailyCasino)
sd(fds$dailyRetail)
sd(fds$dailyPhoto)
sd(fds$dailySpa)
sd(fds$dailyShorex)

summary(shorexlm)
summary(barlm)
summary(retaillm)
summary(photolm)
summary(spalm)
summary(casinolm)
summary(misclm)
summary(commlm)

set.seed(1004)
sampleSize <- floor(.50*nrow(fds))
train <- sample(seq_len(nrow(fds)), size = sampleSize)
tSet <- fds[train, ]
pSet <- fds[-train, ]
shorexlmtSet <- lm(shorexF, data= tSet)
barlmtSet <- lm(barF, data= tSet)
retaillmtSet <- lm(retailF, data= tSet)
photolmtSet <- lm(photoF, data=tSet)
spalmtSet <- lm(spaF, data=tSet)
misclmtSet <- lm(miscF, data=tSet)
commlmtSet <- lm(commF, data=tSet)
casinolmtSet <- lm(casinoF, data=tSet)


# Lift chart
breaks <- 10
t <- pSet[pSet$dailyShorex >0, "dailyShorex"]
shorexActuals <- meansInRanges(t, breaks)
t <- pSet[pSet$dailyBar >0, "dailyBar"]
barActuals <- meansInRanges(t, breaks)
t <- pSet[pSet$dailyRetail >0, "dailyRetail"]
retailActuals <- meansInRanges(t, breaks)
t <- pSet[pSet$dailyPhoto >0, "dailyPhoto"]
photoActuals <- meansInRanges(t, breaks)
t <- pSet[pSet$dailySpa >0, "dailySpa"]
spaActuals <- meansInRanges(t, breaks)
t <- pSet[pSet$dailyMisc >0, "dailyMisc"]
miscActuals <- meansInRanges(t, breaks)
t <- pSet[pSet$dailyComm >0, "dailyComm"]
commActuals <- meansInRanges(t, breaks)
t <- pSet[pSet$dailyCasino >0, "dailyCasino"]
casinoActuals <- meansInRanges(t, breaks)

shorexFit <- predict(shorexlmtSet, newdata=pSet)
barFit <- predict(barlmtSet, newdata=pSet)
retailFit <- predict(retaillmtSet, newdata=pSet)
photoFit <- predict(photolmtSet, newdata=pSet)
spaFit <- predict(spalmtSet, newdata=pSet)
miscFit <- predict(misclmtSet, newdata=pSet)
commFit <- predict(commlmtSet, newdata=pSet)
casinoFit <- predict(casinolmtSet, newdata=pSet)

shorexFitMeans <- meansInRanges(shorexFit, breaks)
barFitMeans <- meansInRanges(barFit, breaks)
retailFitMeans <- meansInRanges(retailFit, breaks)
photoFitMeans <- meansInRanges(photoFit, breaks)
spaFitMeans <- meansInRanges(spaFit, breaks)
miscFitMeans <- meansInRanges(miscFit, breaks)
commFitMeans <- meansInRanges(commFit, breaks)
casinoFitMeans <- meansInRanges(casinoFit, breaks)
liftCharts <- data.frame(shorexActuals, barActuals, retailActuals, photoActuals,  
                         shorexFitMeans, barFitMeans, retailFitMeans, photoFitMeans)
ggplot(data=liftCharts, aes(x=seq_len(nrow(liftCharts)))) + geom_line(aes(y=shorexActuals), color= "red")+
  geom_line(aes(y=shorexFitMeans)) + ggtitle("Shorex Lift")
ggplot(data=liftCharts, aes(x=seq_len(nrow(liftCharts)))) + geom_line(aes(y=barActuals), color= "red")+
  geom_line(aes(y=barFitMeans)) + ggtitle("Bar Lift")
ggplot(data=liftCharts, aes(x=seq_len(nrow(liftCharts)))) + geom_line(aes(y=retailActuals), color= "red")+
  geom_line(aes(y=retailFitMeans)) + ggtitle("Retail Lift")
ggplot(data=liftCharts, aes(x=seq_len(nrow(liftCharts)))) + geom_line(aes(y=photoActuals), color= "red")+
  geom_line(aes(y=photoFitMeans)) + ggtitle("Photo Lift")
ggplot(data=liftCharts, aes(x=seq_len(nrow(liftCharts)))) + geom_line(aes(y=spaActuals), color= "red")+
  geom_line(aes(y=spaFitMeans)) + ggtitle("Spa Lift")
ggplot(data=liftCharts, aes(x=seq_len(nrow(liftCharts)))) + geom_line(aes(y=miscActuals), color= "red")+
  geom_line(aes(y=miscFitMeans)) + ggtitle("Misc Lift")
ggplot(data=liftCharts, aes(x=seq_len(nrow(liftCharts)))) + geom_line(aes(y=commActuals), color= "red")+
  geom_line(aes(y=commFitMeans)) + ggtitle("Comm Lift")
ggplot(data=liftCharts, aes(x=seq_len(nrow(liftCharts)))) + geom_line(aes(y=casinoActuals), color= "red")+
  geom_line(aes(y=casinoFitMeans)) + ggtitle("Casino Lift")

# Per voyage prediciton
perVoyShorexSpend <- #readRDS("~/Coding/R/Rprojects/finalproject/project_data/perVoyShorexSpend.rds") 
  predictVoyageExpenditure(fds, predictionData, "VOYAGE_CD", "SHOREX_REV", shorexlm)
perVoyBarSpend <- #readRDS("~/Coding/R/Rprojects/finalproject/project_data/perVoyBarSpend.rds") 
  predictVoyageExpenditure(fds, predictionData, "VOYAGE_CD", "BAR_REV", barlm)
perVoyRetailSpend <- #readRDS("~/Coding/R/Rprojects/finalproject/project_data/perVoyRetailSpend.rds") 
  predictVoyageExpenditure(fds, predictionData, "VOYAGE_CD", "RETAIL_REV", barlm)
perVoyPhotoSpend <- #readRDS("~/Coding/R/Rprojects/finalproject/project_data/perVoyPhotoSpend.rds") 
  predictVoyageExpenditure(fds, predictionData, "VOYAGE_CD", "PHOTO_REV", photolm)
perVoySpaSpend <- #readRDS("~/Coding/R/Rprojects/finalproject/project_data/perVoySpaSpend.rds") 
   predictVoyageExpenditure(fds, predictionData, "VOYAGE_CD", "SPA_REV", spalm)
perVoyMiscSpend <- #readRDS("~/Coding/R/Rprojects/finalproject/project_data/perVoyMiscSpend.rds") 
  predictVoyageExpenditure(fds, predictionData, "VOYAGE_CD", "MISC_REV", misclm)
perVoyCommSpend <- #readRDS("~/Coding/R/Rprojects/finalproject/project_data/perVoyCommSpend.rds") 
   predictVoyageExpenditure(fds, predictionData, "VOYAGE_CD", "COMM_REV", commlm)
perVoyCasinoSpend <- #readRDS("~/Coding/R/Rprojects/finalproject/project_data/perVoyCasinoSpend.rds") 
   predictVoyageExpenditure(fds, predictionData, "VOYAGE_CD", "CASINO_REV", casinolm)

# saveRDS(perVoyCasinoSpend, "~/Coding/R/Rprojects/finalproject/project_data/perVoyCasinoSpend.rds")

ss <- floor(.9*nrow(perVoyShorexSpend))
set.seed(1002)
ssRows <- sample(seq_len(nrow(perVoyShorexSpend)), size=ss)
subsampShorex <- perVoyShorexSpend[ssRows, ]
subsampBar <- perVoyBarSpend[ssRows, ]
subsampRetail <- perVoyRetailSpend[ssRows, ]
subsampPhoto <- perVoyPhotoSpend[ssRows, ]
subsampSpa <- perVoySpaSpend[ssRows, ]
subsampMisc <- perVoyMiscSpend[ssRows, ]
subsampComm <- perVoyCommSpend[ssRows, ]
subsampCasino <- perVoyCasinoSpend[ssRows, ]

ggplot(data=subsampShorex, aes(x=Voyage)) + 
  geom_line(data=subsampShorex, aes(y=Actual), size=1 ) +
  geom_line(data=subsampShorex, aes(y=Predicted), color= "red") +
  ggtitle("Shorex Fit")
ggplot(data=subsampBar, aes(x=Voyage)) + 
  geom_line(data=subsampBar, aes(y=Actual), size=1 ) +
  geom_line(data=subsampBar, aes(y=Predicted), color= "red") + 
  ggtitle("Bar Fit")
ggplot(data=subsampRetail, aes(x=Voyage)) +
  geom_line(data=subsampRetail, aes(y=Actual), size=1 ) +
  geom_line(data=subsampRetail, aes(y=Predicted), color= "red") + 
  ggtitle("Retail Fit")
ggplot(data=subsampPhoto, aes(x=Voyage)) + 
  geom_line(data=subsampPhoto, aes(y=Actual), size=1 ) +
  geom_line(data=subsampPhoto, aes(y=Predicted), color= "red") +
  ggtitle("Photo Fit")
ggplot(data=subsampSpa, aes(x=Voyage)) + 
  geom_line(data=subsampSpa, aes(y=Actual), size=1 ) +
  geom_line(data=subsampSpa, aes(y=Predicted), color= "red") + 
  ggtitle("Spa fit")
ggplot(data=subsampMisc, aes(x=Voyage)) + 
  geom_line(data=subsampMisc, aes(y=Actual), size=1 ) +
  geom_line(data=subsampMisc, aes(y=Predicted), color= "red") +
  ggtitle("Misc Fit")
ggplot(data=subsampComm, aes(x=Voyage)) + 
  geom_line(data=subsampComm, aes(y=Actual), size=1 ) +
  geom_line(data=subsampComm, aes(y=Predicted), color= "red") +
  ggtitle("Comm Fit")
ggplot(data=subsampCasino, aes(x=Voyage)) + 
  geom_line(data=subsampCasino, aes(y=Actual), size=1 ) +
  geom_line(data=subsampCasino, aes(y=Predicted), color= "red") +
  ggtitle("Casino Fit")


# Assume 90% of the data is between 0 and 62
a0 <- 6
d0 <- 6000
B0diag <- 1e-6
sumShorexlm <- summary(shorexlmtSet)
b0 <- sumShorexlm$coefficients[,1]
shorexmc <- MCMCregress(shorexF, data = tSet, b0=b0, B0= B0diag, c0=a0, d0=d0)
summary(shorexmc)
table(fds$CRUISE_START_DATE)

# Time Series
dateCuts <- getDateCuts()
dateCuts
dateCuts <- dateCuts[-c(1:8, 45:48)]
dateCuts
length(dateCuts)
brev <- getColNumber(fds, "BAR_REV")
crev <- getColNumber(fds, "CASINO_REV")
monthSums <- matrix(0, nrow=length(dateCuts)-1, ncol=crev-brev+2)
monthSums
for(i in 2:length(dateCuts)){
  t <- fds[fds$CRUISE_START_DATE <= dateCuts[i] & fds$CRUISE_START_DATE > dateCuts[i-1], ]
  monthSums[i-1,1] <- dateCuts[i]
  monthSums[i-1, 2:9] <- apply(t[, brev:crev], 2, sum, na.rm=TRUE)
}
monthSums <- data.frame(monthSums)
monthSums[,1] <- as.Date(monthSums[,1])
monthSums
yearSums2014 <- apply(monthSums[4:15,2:9], 2, sum)
yearSums2015 <- apply(monthSums[16:27, 2:9], 2, sum)
names <- c("Bar", "Photo", "Spa", "Shorex", "Misc", "Comm", "Retail", "Casino")
yearlySums <- data.frame(cbind(names, yearSums2014, yearSums2015))
yearlySums[,2] <- as.numeric(as.character(yearlySums[,2]))
yearlySums[,3] <- as.numeric(as.character(yearlySums[,3]))
yearlySums <- yearlySums[order(-yearlySums$yearSums2014), ]
yearlySums
yearlySums <- melt(yearlySums)
yearlySums
yearlySums <- yearlySums[order(-yearlySums$value), ]


ggplot(yearlySums, aes(x=variable, y=value, fill=names)) + 
  geom_bar(stat="identity", width = .50) +
  scale_fill_discrete("Department") +
  xlab("Year") +
  ylab("Revenue")

monthSums <- monthSums[-c(1:3),]

timeSeries <- ts(monthSums, start=c(2014, 1), end=c(2016,8), frequency = 12)
timeSeries
adf.test(timeSeries[,2])
Acf(timeSeries[,2])
Pacf(timeSeries[,2])
ft <- arima(timeSeries[,2], order=c(10,1,0))
Acf(ft$residuals)
Pacf(ft$residuals)
adf.test(ft$residuals)
accuracy(ft)
HoltWinters()
plot.forecast(ft, h =4)

fore <- timeSeriesHelper(ft, timeSeries, 4, 2)
act <- c(timeSeries[2:32,2], numeric(4))
fore <- cbind(dateCuts[14:length(dateCuts)], fore, act)
fore <- data.frame(fore)
fore[,1] <- as.Date(fore[,1])
fore
ggplot() + geom_point(data=fore[1:32,], aes(x=V1, y=fore), color="red") + 
  geom_line(data=fore[1:32,], aes(x=V1, y=fore), color="red") +
  geom_point(data=fore[1:31,], aes(x=V1, y=act)) + 
  geom_line(data=fore[1:31,], aes(x=V1, y=act)) +
  ylab("Revenue") + xlab("Date") +
  ggtitle("Shorex Time Series Analysis\nRed-Forecast, Black-Observed")

length(timeSeries[,2])
timeSeriesHelper(ft, timeSeries, 4, 2)



