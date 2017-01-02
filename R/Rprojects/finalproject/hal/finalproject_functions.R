# source('~/R/Rprojects/finalproject/obrfunctions.R')
source('/Users/dillonflannery-valadez/Google Drive/Coding/R/Rprojects/finalproject/HAL/obrfunctions.R')
# NOTE: Took zip out of subset 7/28/16 to use it in ggmap
cleanup <- function(finaldat){
  finaldat <- subset(finaldat, select=-c(CRUISE_START_DATE, CRUISE_END_DATE, PAX_MARINER_NO,
                                         BKNG_ID, PAX, SHIPCLASSDESC, ZIP))
  finaldat$BAR_REV <- as.numeric(as.character(finaldat$BAR_REV))
  finaldat <- finaldat[!is.na(finaldat$CRUISELENGTH),]
  finaldat
}

prepData <- function(finaldat){
  finaldat <- cleanup(finaldat)
  revenueVars <- getColNumbers(finaldat, "BAR_REV", "CASINO_REV")
  finaldat[, revenueVars] <- naZero(finaldat[,revenueVars])
  revenueTotal <- getRevenueTotals(finaldat[,revenueVars])
  spendPerDay <- revenueTotal/finaldat$CRUISELENGTH
  finaldat <- cbind(spendPerDay, finaldat)
  colnames(finaldat)[1] <- "onBoardDailySpend"
  revenueVars <- getColNumbers(finaldat, "BAR_REV", "CASINO_REV")
  # finaldat <- finaldat[, c(1, revenueVars, 2:12, 21:ncol(finaldat))]
  totalSpent <- revenueTotal + finaldat$NTR
  colnames(totalSpent)[1] <- "totalSpent"
  totalSpendPerDay <- totalSpent / finaldat$CRUISELENGTH
  colnames(totalSpendPerDay)[1] <- "totalSpendPerDay"
  finaldat <- cbind(totalSpent, totalSpendPerDay, finaldat)
  finaldat
}

renameLevels <- function(dataset){
  levels(dataset$INCOME)[1] <- NA
  levels(dataset$INCOME)[1:2] <- "100000-124999"
  levels(dataset$INCOME)[2:4] <- "125000-250000"
  levels(dataset$INCOME)[3:4] <- "20000-29999"
  levels(dataset$INCOME)[4:5] <- "Over 250000"
  levels(dataset$INCOME)[5:7] <- "30000-49999"
  levels(dataset$INCOME)[6:8] <- "50000-69999"
  levels(dataset$INCOME)[7:10] <- "70000-99999"
  print(summary(dataset$INCOME))
  dataset$INCOME <- factor(dataset$INCOME, levels(dataset$INCOME)[c(9, 3, 5, 6, 7, 1, 2, 4, 8, 10)])
  levels(dataset$INCOME)[9:10] <- NA
  print(summary(dataset$INCOME))
  dataset$INCOME
}

getData <- function(dataset){
  d <- prepData(dataset)
  d$INCOME <- renameLevels(d)
  dataset <- dataset[!is.na(dataset$CRUISELENGTH),]
  d <- cbind(d, dataset$ZIP)
  colnames(d)[ncol(d)] <- "ZIP"
  d
}

getMissingLatLonCoors <- function(){
  missingLongs <- c(127.9785, 19.69902, -3.74922, 8.227512, 120.9605)
  missingLats <- c(37.664, 48.66903, 40.46367, 46.81819, 23.69781)
  missingCountryLatLon <- cbind(missingLongs, missingLats)
  rownames(missingCountryLatLon) <- c("KOREA Republic of South Korea", "SLOVAKIA (Slovak Republic)",
                                      "SPAIN (Espa?a)", "SWITZERLAND (Confederation of Helvetia)",
                                      "TAIWAN (Chinese Taipei for IOC)")
  missingCountryLatLon
}

getGeocodes <- function(df){
  countryNames <- as.matrix(levels(df$NATIONALITY))
  latlon <- matrix(nrow= nrow(countryNames), ncol=2)
  rownames(latlon) <- countryNames
  for(i in 1:nrow(countryNames)){
    latlono <- geocode(countryNames[i])
    latlon[i,1] <- latlono$lon
    latlon[i,2] <- latlono$lat
  }
  latlon <- latlon[2:nrow(latlon),]
}

fillMissingData <- function(latlon, missingdata){
  rowNamesMissings <- rownames(missingdata)
  for(i in 1:length(rowNamesMissings)){
    latlon[rowNamesMissings[i],] <- missingdata[i,]
  }
  latlon
}

attachLatLon <- function(finaldat, latlon){
  forCountry <-  finaldat[!is.na(finaldat$NATIONALITY),]
  charNation <- as.character(forCountry$NATIONALITY)
  countryCoors <- matrix(nrow=nrow(forCountry), ncol=2)
  for(i in 1:length(charNation)){
    countryCoors[i, ] <- latlon[charNation[i],]
  }
  forCountry <- cbind(forCountry, countryCoors)
  colnames(forCountry)[ncol(forCountry)] <- "Latitude"
  colnames(forCountry)[ncol(forCountry) -1] <- "Longitude"
  forCountry
}
  
getStateLatLon <- function(uspeeps, state_zcode){
  rows <- nrow(uspeeps)
  latLon <- matrix(rep(0,4), nrow=1)
  for(i in 1:nrow(state_zcode)){
    tempStateZipCodeRow <- state_zcode[i,]
    temp <- uspeeps[uspeeps$STATE == as.character(tempStateZipCodeRow[2]), ]
    tempRowNum <- nrow(temp)
    tempLatLon <- matrix(t(rep(tempStateZipCodeRow, tempRowNum)), ncol=4, byrow=TRUE)
    latLon <- rbind(latLon, tempLatLon)
  }
  latLon <- as.data.frame(matrix(unlist(latLon), ncol=4))
  cNames <- c("region", "STATE_CODE", "Latitude", "Longitude")
  colnames(latLon) <- cNames
  latLon$Latitude <- as.numeric(as.character(latLon$Latitude))
  latLon$Longitude <- as.numeric(as.character(latLon$Longitude))
  latLon[2:nrow(latLon),]
}

getLatLonUSAPeeps <- function(finaldat){
  uspeeps <- finaldat[finaldat$NATIONALITY=="UNITED STATES", ]
  uspeeps <- uspeeps[!is.na(uspeeps$STATE), ]
  uspeepswithLL <- getStateLatLon(uspeeps, zipcode)
  uspeepswithLL <- as.data.frame(uspeepswithLL)
  cols <- ncol(uspeepswithLL)
  colnames(uspeepswithLL)[cols-1] <- "Longitude"
  colnames(uspeepswithLL)[cols] <- "Latitude"
}

MCMCcoefs <- function(summaryObj){
  coefList <- data.frame(summaryObj[[1]])
  coefs <- 0
  for(i in 1:nrow(coefList)){
    coefs[i] <- coefList[i,1]
  }
  coefs
}

getQuantiles <- function(varName, numQuants){
  interval <- .9/numQuants
  cuts <- seq(.1,.9, by=interval)
  lcuts <- length(cuts)
  quants <- rep(0, lcuts)
  for(i in 1:lcuts){
    quants[i] <- quantile(varName, cuts[i])
  }
  quants
}

meansInRanges <- function(varName, breaks, userBreaks = 0){
  if(length(userBreaks)  < 2){
    quants <- getQuantiles(varName, breaks)
    quants <- c(0, quants)
    lquants <- length(quants)
    avgs <- numeric(lquants)
  }
  else{
    quants <- c(0, userBreaks)
    lquants <- length(quants)
    avgs <- numeric(lquants)
  }
  for(i in 2:lquants){
    if(i == lquants){
      avgs[i] <- mean(varName[varName > quants[i]])
    }
    else{
      avgs[i] <- mean(varName[varName< quants[i] & varName > quants[i-1]])
    }
  }
  avgs[-1]
}

errorBounds <- function(predicitonData, lmFormula){
  lmResults <- summary(lmFormula)
  nCoefs <- nrow(lmResults$coefficients)
  errorMargin <- matrix(NA, nrow = nCoefs, ncol=3)
  for(i in 1:nCoefs){
    errorMargin[i, 1] <-  lmResults$coefficients[i,1] + lmResults$coefficients[i, 2]
    errorMargin[i, 2] <-   lmResults$coefficients[i,1] - lmResults$coefficients[i, 2]
  }
  upperBound <- numeric(length= nrow(predictionData))
  lowerBound <- numeric(length=nrow(predictionData))
  predictions <- predictionData %*% lmResults$coefficients[,1]
  upperBound <- predictionData %*% errorMargin[,1]
  lowerBound <- predictionData %*% errorMargin[,2]
  upperLowerBound <- data.frame(cbind(predictions, upperBound, lowerBound))
  colnames(upperLowerBound) <- c("Predictions", "UpperBound", "LowerBound")
  upperLowerBound
}

predictVoyageExpenditure <- function(dataset, predictionData, voyage_code, revenueVar, lmFormula){
  errs <- errorBounds(predictionData, lmFormula)
  dataset <- cbind(dataset, errs)
  ubColNum <- getColNumber(dataset, "UpperBound")
  lbColNum <- getColNumber(dataset, "LowerBound")
  predsColNum <- getColNumber(dataset, "Predictions")
  voyageCodeColNum <- getColNumber(dataset, voyage_code)
  crLenColNum <- getColNumber(dataset, "CRUISELENGTH")
  revCol <- getColNumber(dataset, revenueVar)
  voyages <- levels(dataset[, voyageCodeColNum])
  lVoys <- length(voyages)
  perVoyageSpend <- data.frame(matrix(0 ,nrow=lVoys, ncol=6))
  voyTable <- table(dataset[, voyageCodeColNum])
  count <- 0
  for(i in 1:lVoys){
    if(voyTable[i] > 800){
      count <- count + 1
      perVoy <- dataset[dataset[,voyageCodeColNum] == voyages[i], ]
      cruiseLen <- perVoy[,crLenColNum][1]
      perVoyageSpend[count, 1] <- count
      perVoyageSpend[count, 2] <- voyages[i]
      perVoyageSpend[count, 3] <- sum(perVoy[, revCol], na.rm=TRUE) 
      perVoyageSpend[count, 4] <- sum(perVoy[, predsColNum], na.rm=TRUE) * cruiseLen
      perVoyageSpend[count, 5] <- sum(perVoy[, ubColNum], na.rm=TRUE) * cruiseLen
      perVoyageSpend[count, 6] <- sum(perVoy[, lbColNum], na.rm=TRUE) * cruiseLen
    }
  }
  perVoyageSpend <-  data.frame(perVoyageSpend)
  colnames(perVoyageSpend) <- c("Voyage", "Voyage_cd", "Actual", "Predicted", 
                                "UpperBound", "LowerBound")
  perVoyageSpend <- perVoyageSpend[perVoyageSpend$Actual != 0, ]
  perVoyageSpend
}

predictHierarchical <- function(dataset, voyage_code, revenueVar, hierarchyColumn, hierarchyLevel, 
                                hierarchical=TRUE){
  crLenColNum <- getColNumber(dataset, "CRUISELENGTH")
  revCol <- getColNumber(dataset, revenueVar)
  hierCol <- getColNumber(dataset, hierarchyColumn)
  if(hierarchical == TRUE){
    predsColNum <- getColNumber(dataset, "H_Preds")  
  }
  else{
    predsColNum <- getColNumber(dataset, "Predictions")
  }
  voyageCodeColNum <- getColNumber(dataset, voyage_code)
  # Take every cruise that twent to a certain place, e.g.
  reducedDataset <- subset(dataset, dataset[,hierCol] == hierarchyLevel)
  reducedDataset[, voyageCodeColNum] <- factor(reducedDataset[, voyageCodeColNum])
  voyTable <- table(reducedDataset[,voyageCodeColNum])
  lVoys <- length(voyTable)
  voyages <- levels(reducedDataset[,voyageCodeColNum])
  perVoyageSpend <- data.frame(matrix(0 ,nrow=lVoys, ncol=3))
  count <- 0
  for(i in 1:lVoys){
    if(voyTable[i] > 800){
      count <- count + 1
      # Take all voyages going to a certain place and loop through them.
      perVoy <- reducedDataset[reducedDataset[,voyageCodeColNum] == voyages[i], ]
      cruiseLength <- perVoy[, crLenColNum][1]
      perVoyageSpend[count, 1] <- voyages[i]
      perVoyageSpend[count, 2] <- sum(perVoy[,revCol], na.rm = TRUE) 
      perVoyageSpend[count, 3] <- sum(perVoy[, predsColNum], na.rm=TRUE) * cruiseLength
    }
  }
  perVoyageSpend <- perVoyageSpend[perVoyageSpend[,1] != 0, ]
  colnames(perVoyageSpend) <- c("Voyage_cd", "Actual", "Predicted")
  perVoyageSpend
}

getDateCuts <- function(){
  months <- seq_len(12)
  years <- seq(2013,2016)
  monthly_avgs <- numeric(length(months)*length(years))
  monthDays <- c(31, 28, 31, 30, 31, 30, 31, 31, 30,31, 30, 31)
  dateCuts <- numeric(length(months)*length(years))
  c <- 0
  for(j in years){
    for(i in months){
      c <- c + 1
      if(j == 2016 & i ==2){
        dateCuts[c] <- sprintf("%i-%i-29", j, i)
        print(date)
      }
      else{
        dateCuts[c] <- sprintf("%i-%i-%i", j, i, monthDays[i])
      }
    }
  }
  dateCuts <- as.Date(dateCuts)
  dateCuts
}

timeSeriesHelper <- function(forecastObj, timeSeriesObj, periodsOut, column){
  model <- forecast(forecastObj, periodsOut)
  out <- model$mean
  backFits <- model$fitted
  seriesLen <- length(timeSeriesObj[,column])
  outVec <- c(backFits, out)
  outVec
}

calcRelativeErrs <- function(data, predictionDataLM, predictionDataH, lmResults, hierCoefsVec, 
                             trade, department){
  regionData <- newModel(data, predictionDataLM, predictionDataH, lmResults, hierCoefsVec)
  lmPredict <- predictHierarchical(regionData,"VOYAGE_CD", department, "TRADE", trade, 
                                   hierarchical= FALSE)
  hierarchicalPredict <- predictHierarchical(regionData, "VOYAGE_CD", department, "TRADE", trade)
  lmPredictPercentError <- (lmPredict$Actual - lmPredict$Predicted) / lmPredict$Actual
  hierarchicalPercentError <- (hierarchicalPredict$Actual - hierarchicalPredict$Predicted) /
    hierarchicalPredict$Actual
  percentError <- data.frame(lmPredictPercentError, hierarchicalPercentError)
  colnames(percentError) <- c("lm", "Hierarchical")
  percentError
}

newModel <- function(data, predictionDataLM, predictionDataH, lmResults, hierCoefsVec){
  H_Preds <- predictionDataH %*% as.numeric(hierCoefsVec)
  data <- cbind(data, H_Preds)
  ulb <- errorBounds(predicitonData = predicitonDataLM, lmResults)
  data <- cbind(data, ulb)
  data
}

rootMSE <- function(validationSet, hierarchicalCoefs, linearCoefs, hierarchicalX, linearX, revVar){
  names <- rownames(hierarchicalCoefs)
  revColNum <- getColNumber(validationSet, revVar)
  errors <- as.data.frame(matrix(0, nrow=length(names), ncol=6))
  predictions <- list(2*length(names))
  for(i in 1:length(names)){
    destinationIndices <- validationSet$TRADE == names[i] 
    truth <- validationSet[destinationIndices,][ ,revColNum]
    XH <- hierarchicalX[destinationIndices,]
    XL <- linearX[destinationIndices,]
    predHier <- XH %*% as.numeric(hierarchicalCoefs[i,])
    predLin <- XL %*% as.numeric(linearCoefs)
    errH <- round(sum((predHier - truth)^2),3)
    errL <- round(sum((predLin - truth)^2),3)
    errors[i,1:6] <- c(names[i], errH, errL, round(sqrt(errH),3), round(sqrt(errL),3),
                       round(sqrt(errH) - sqrt(errL),3))
    predictionIndex <- 2*i - 1
    predictions[[predictionIndex]] <- predHier
    predictions[[predictionIndex + 1]] <- predLin
  }
  colnames(errors) <- c('TRADE', 'MSE H-Model', 'MSE L-Model', 'Root MSE H-Model', 'Root MSE L-Model',
                        'Difference (H - L)')
  list(errors, predictions)
}

saveModel <- function(path, objToSave){
  saveRDS(objToSave, file=paste(paste(path, deparse(substitute(objToSave)), sep=''),
                                '.rds',sep='' ))
}
