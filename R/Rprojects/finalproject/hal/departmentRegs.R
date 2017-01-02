# New regression by department. Comparison of three biggest departments shorex, bar, retail

barF <- dailyBar ~ NTR + SHIPNAME + TRADE + PAX_AGE + CRUISELENGTH + 
  NATIONALITY + X_META + PAX_LOYALTY + EGSS_OVERALL + EGSS_BAR + INCOME + PAX_GENDER
barlm <- lm(barF, data= cdNation)
photoF <- dailyPhoto ~ NTR + SHIPNAME + TRADE + PAX_AGE + CRUISELENGTH + 
  NATIONALITY + X_META + PAX_LOYALTY + EGSS_OVERALL + EGSS_PHOTO + INCOME + PAX_GENDER
photolm <- lm(photoF, data=cdNation)
spaF <- dailySpa ~ NTR + SHIPNAME + TRADE + PAX_AGE + CRUISELENGTH + 
  NATIONALITY + X_META + PAX_LOYALTY + EGSS_OVERALL + EGSS_SPA + INCOME + PAX_GENDER
spalm <- lm(spaF, data=cdNation)
shorexF <- dailyShorex ~ NTR + SHIPNAME + TRADE + PAX_AGE + CRUISELENGTH + 
  NATIONALITY + X_META + PAX_LOYALTY + EGSS_OVERALL + INCOME + PAX_GENDER
shorexlm <- lm(shorexF, data= cdNation)
miscF <- dailyMisc ~ NTR + SHIPNAME + TRADE + PAX_AGE + CRUISELENGTH +
  NATIONALITY + X_META + PAX_LOYALTY + EGSS_OVERALL  + INCOME + PAX_GENDER
misclm <- lm(miscF, data= cdNation)
commF <- dailyComm ~ NTR + SHIPNAME + TRADE + PAX_AGE + CRUISELENGTH + 
  NATIONALITY + X_META + PAX_LOYALTY + EGSS_OVERALL  + INCOME + PAX_GENDER
commlm <- lm(miscF, data= cdNation)
retailF <- dailyRetail ~ NTR + SHIPNAME + TRADE + PAX_AGE + CRUISELENGTH + 
  NATIONALITY + X_META + PAX_LOYALTY + EGSS_OVERALL + EGSS_RETAIL+ INCOME + PAX_GENDER
retaillm <- lm(retailF, data= cdNation)
casinoF <- dailyCasino ~ NTR + SHIPNAME + TRADE + PAX_AGE + CRUISELENGTH + 
  NATIONALITY + X_META + PAX_LOYALTY + EGSS_OVERALL  + EGSS_CASINO + INCOME + PAX_GENDER
casinolm <- lm(casinoF, data= cdNation)


barmc <- MCMCregress(barF, data=cdNation)
photomc <- MCMCregress(photoF, data=cdNation)
spamc <- MCMCregress(spaF, data= cdNation)
sd <- cdNation
sd$TRADE <- factor(sd$TRADE)
table(sd$TRADE)

shorexmc <- MCMCregress(shorexF, data=sd)
miscmc <- MCMCregress(miscF, data=cdNation)
commmc <- MCMCregress(commF, data=cdNation)

retailmc <- MCMCregress(retailF, data=cdNation)
casinomc <- MCMCregress(casinoF, data=cdNation)

summary(barlm)
summary(barmc)

sumShorexlm <- summary(shorexlm)
summary(shorexmc)

summary(retaillm)
summary(retailmc)

# Set up training and validation sets
set.seed(1004)
sampleSize <- floor(.80*nrow(cdNation))
train <- sample(seq_len(nrow(cdNation)), size = sampleSize)

tSet <- cdNation[train, ]
tSet <- tSet[tSet$BAR_REV >0 ,]

pSet <- cdNation[-train, ]
pSet <- pSet[pSet$BAR_REV >0 , ]

barlm <- lm(barF, data=tSet)
shorexlm <- lm(shorexF, data=tSet)
retaillm <- lm(retailF, data= tSet)


# Bayesian Regression done right
barlmtrain <- summary(barlm)
barlmtrain
mean(barlmtrain$residuals^2)
b0 <- barlmtrain$coefficients[,1]
smallNum <- 1e-6
B0 <- rep(smallNum, length(b0))
summary(tSet$BAR_REV)
hist((tSet$BAR_REV))
boxplot(tSet$BAR_REV)
quantile(tSet$BAR_REV, .90)
alpha0 <- 6
delta0 <- 80000
barmcTrain <- MCMCregress(barF, data=tSet, thin=2, seed=1005, b0=b0,B0=B0, c0=alpha0, d0=delta0)
summary(barmcTrain)
barTrainSumMC <- summary(barmcTrain)
barTrainCoefs <- MCMCcoefs(barTrainSumMC)
barTrainCoefs <- barTrainCoefs[-length(barTrainCoefs)]
barTrainCoefs

# Generate dummies for matrix to multiply coefficients and 
# get predictors.
shipDummies <- dummy(pSet$SHIPNAME)[,-1]
tradeDummies <- dummy(pSet$TRADE)[,-1]
cruiselengthDummies <- dummy(pSet$CRUISELENGTH)[,-1]
nationalityDummies <- dummy(pSet$NATIONALITY)[,-1]
xMetaDummies <- dummy(pSet$X_META)[,-1]
loyaltyDummies <- dummy(pSet$PAX_LOYALTY)[,-1]
incomeDummies <- dummy(pSet$INCOME)[,-1]
genderDummies <- dummy(pSet$PAX_GENDER)[,-1]

bayesData <- cbind(rep(1, nrow(pSet)), pSet$NTR, shipDummies,tradeDummies, pSet$PAX_AGE, cruiselengthDummies, 
      nationalityDummies, xMetaDummies, loyaltyDummies,pSet$EGSS_OVERALL, pSet$EGSS_BAR, incomeDummies,
      genderDummies)

dim(bayesData)
pBayes <- bayesData %*% barTrainCoefs
bayesFittedActual <- data.frame(cbind(pBayes, pSet$dailyBar))
bayesFittedActual <- bayesFittedActual[!is.na(bayesFittedActual$X1),]
obLen <- seq_len(nrow(bayesFittedActual))
bayesFittedActual <- cbind(obLen, bayesFittedActual)
colnames(bayesFittedActual) <- c("obs", "predicted", "actual")
ggplot(bayesFittedActual, aes(x=obLen)) +  
  geom_line(data=bayesFittedActual, aes(y=actual, colour="Actual")) + ylab("Spend Per Day") +
  geom_line(data=bayesFittedActual, aes(y=predicted, colour="Predicted")) +
  scale_colour_manual(values=c( "Actual"="blue", "Predicted"="red"))

bayesMeansPred <- meansInRanges(bayesFittedActual$predicted, 10)
bayesMeansAct <- meansInRanges(bayesFittedActual$actual, 10)
obs <- seq_len(length(bayesMeansAct))
bayesMeans <- data.frame(cbind(obs, bayesMeansAct, bayesMeansPred))
ggplot(bayesMeans, aes(x=obs)) + geom_line(aes(y=bayesMeansAct, colour="Actual")) + 
  geom_line(aes(y=bayesMeansPred, colour = "Predicted")) +
  scale_colour_manual(values= c("Actual"= "blue", "Predicted"= "red"))
# End Bayes

# Prediction and analysis of fit, lm
predicted <- predict(barlm, newdata=pSet)
fittedActual <- cbind(predicted, pSet$dailyBar)
fittedActual <- fittedActual[!is.na(fittedActual[,1]), ]
obs <- seq_len(nrow(fittedActual))
fittedActual <- data.frame(cbind(obs, fittedActual))

actualMeans <- meansInRanges(fittedActual$V3, 10)
predictedMeans <- meansInRanges(fittedActual$predicted, 10)
numMeans <- seq_len(length(actualMeans))
actPredMeans <- data.frame(cbind(numMeans, actualMeans, predictedMeans))
ggplot(actPredMeans, aes(x=numMeans)) + geom_line(aes(y=actualMeans, colour="Actual")) + 
  geom_line(aes(y=predictedMeans, colour="Predicted")) + 
  scale_colour_manual(values = c("Actual"= "blue", "Predicted" = "red"))
ggplot(fittedActual, aes(x=obs)) + geom_line(data=fittedActual, aes(y=V3, colour="Actual")) +
  geom_line(data=fittedActual, aes(y=predicted, color="Predicted")) + 
  scale_colour_manual(values=c("Actual" = 'blue', "Predicted"="red")) + ylab("Spending Per Day")


# Predictions per voyage
# Error range:
nCoefs <- nrow(sumShorexlm$coefficients)
errorMargin <- matrix(NA, nrow = nCoefs, ncol=2)
for(i in 1:nCoefs){
  errorMargin[i, 1] <-  sumShorexlm$coefficients[i,1] + sumShorexlm$coefficients[i, 2]
  errorMargin[i, 2] <-   sumShorexlm$coefficients[i,1] - sumShorexlm$coefficients[i, 2]
}

# Create data with actual dummy vectors to use the error margins with matrix mult.
shipDummies <- dummy(cdNation$SHIPNAME)[,-1]
tradeDummies <- dummy(cdNation$TRADE)[,-1]
cruiselengthDummies <- dummy(cdNation$CRUISELENGTH)[,-1]
nationalityDummies <- dummy(cdNation$NATIONALITY)[,-1]
xMetaDummies <- dummy(cdNation$X_META)[,-1]
loyaltyDummies <- dummy(cdNation$PAX_LOYALTY)[,-1]
incomeDummies <- dummy(cdNation$INCOME)[,-1]
genderDummies <- dummy(cdNation$PAX_GENDER)[,-1]

# shorexF <- dailyShorex ~ NTR + SHIPNAME + TRADE + PAX_AGE + CRUISELENGTH + 
#   NATIONALITY + X_META + PAX_LOYALTY + EGSS_OVERALL + INCOME + PAX_GENDER

dataForPrediction <- cbind(rep(1, nrow(cdNation)), cdNation$NTR, shipDummies, tradeDummies, cdNation$PAX_AGE, 
                   cruiselengthDummies, nationalityDummies, xMetaDummies, loyaltyDummies, 
                   cdNation$EGSS_OVERALL,  incomeDummies, genderDummies)

upperBound <- numeric(length= nrow(dataForPrediction))
lowerBound <- numeric(length=nrow(dataForPrediction))
upperBound <- dataForPrediction %*% errorMargin[,1]
lowerBound <- dataForPrediction %*% errorMargin[,2]
cdNation <- cbind(cdNation, upperBound, lowerBound)

# Predict on a voyage basis
lVoy <- length(voyages) 
voyages <- levels(cdNation$VOYAGE_CD)
results <- matrix(NA, nrow=lVoy, ncol=5)
for(i in 1:lVoy){
  voy <- cdNation[cdNation$VOYAGE_CD == voyages[i], ]
  results[i, 1] <- i
  results[i, 2] <- sum(voy$dailyShorex)
  results[i, 3] <- sum(predict(shorexlm, newdata=voy))  
  results[i, 4] <- sum(voy$upperBound)
  results[i, 5] <- sum(voy$lowerBound)
}
colnames(results) <- c("Voyage", "Actual", "Predicted", "UpperBound", "LowerBound")
head(results)
results <- data.frame(results)
ggplot(data=results, aes(x=Voyage)) + geom_line(data=results, aes(y=Actual, colour="Actual")) + 
  geom_line(data=results, aes(y=Predicted, colour="Predicted"), size=1) +
  geom_line(data=results, aes(y= UpperBound, colour="Upper/Lower\n Bound"), linetype=2) +
  geom_line(aes(y=LowerBound), linetype=2, colour="red") +
  scale_colour_manual(name ="", values=c("Actual"="blue", "Predicted"= "green1", "Upper/Lower\n Bound" = "red")) +
  ylab("Daily Shorex Spend") + xlab("Per Voyage") + 
  ggtitle("Actual/Predicted Per Voyage Shorex Expenditure\n Plotted With 1 Standard Deviation Of Predictors")

