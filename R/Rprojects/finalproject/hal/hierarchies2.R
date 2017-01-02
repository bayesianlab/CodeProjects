source('~/Coding/R/Rprojects/finalproject/finalproject_functions.R')
fds <- readRDS("~/Coding/R/Rprojects/finalproject/project_data/fds.rds")
predictionData <- readRDS("~/Coding/R/Rprojects/finalproject/project_data/predictionData.rds")

# Hierarchical lm 
shorexF <- dailyShorex ~ NTR_PCD + PAX_AGE  + BOOK_TO_CRUISE_TIME_DIFF  + CRUISELENGTH +
  SHIPNAME + TRADE + NATIONALITY + X_META + PAX_LOYALTY + PAX_GENDER
shorexlm <- lm(shorexF, data= fds)

shipDummies <- dummy(fds$SHIPNAME)[,-1]
tradeDummies <- dummy(fds$TRADE)[,-1]
cruiselengthDummies <- dummy(fds$CRUISELENGTH)[,-1]
nationalityDummies <- dummy(fds$NATIONALITY)[,-1]
xMetaDummies <- dummy(fds$X_META)[,-1]
loyaltyDummies <- dummy(fds$PAX_LOYALTY)[,-1]
incomeDummies <- dummy(fds$INCOME)[,-1]
genderDummies <- dummy(fds$PAX_GENDER)[,-1]
predictionDataH <- cbind(rep(1, nrow(fds)), fds$NTR_PCD, fds$PAX_AGE, fds$BOOK_TO_CRUISE_TIME_DIFF, fds$CRUISELENGTH, 
                               shipDummies, nationalityDummies, xMetaDummies, loyaltyDummies, genderDummies)

shorexHierarchicalF <- dailyShorex ~ NTR_PCD + PAX_AGE + BOOK_TO_CRUISE_TIME_DIFF  +  
  CRUISELENGTH + SHIPNAME + NATIONALITY+ X_META + PAX_LOYALTY + PAX_GENDER  + (1 | TRADE)
shorexH <- lmer(shorexHierarchicalF , data=fds, REML=FALSE)
summary(shorexH)
hierCoefs <- coef(shorexH)
dim(predictionDataH)
preds <- predictionDataH %*% as.numeric(hierCoefs[[1]][5,])
fds <- cbind(fds, preds)

lmPredict <- predictVoyageExpenditure(fds, predicitonData, "VOYAGE_CD", "SHOREX_REV", shorexlm)
hierarchicalPredict <- predictHierarchical(fds, "VOYAGE_CD", "SHOREX_REV", "TRADE", "CARIBBEAN")


ggplot() + geom_point(data=lmPredict, aes(x=Voyage_cd, y=Actual)) +
  geom_point(data=lmPredict, aes(x=Voyage_cd, y=Predicted), color="red")

ggplot() + geom_point(data=y, aes(x=Voyage_cd, y=Actual)) +
  geom_point(data=y, aes(x=Voyage_cd, y=Predicted), color="red")

compare <- merge(y,x,by="Voyage_cd")
compare <- compare[-c(1, 14), ]
ggplot() + geom_jitter(data=compare, aes(x=Voyage_cd, y=Actual.x)) +
  geom_jitter(data=compare, aes(x=Voyage_cd, y=Predicted.x), color="red") + 
  geom_jitter(data=compare, aes(x=Voyage_cd, y=Predicted.y), color="blue") 
  
hierarchicalPredict2 <- predictHierarchical(fds, "VOYAGE_CD", "SHOREX_REV", "TRADE", "CARIBBEAN")
compare2 <- merge(lmPredict, hierarchicalPredict2, by="Voyage_cd")
compare2$Actual.x - compare2$Actual.y
lmErr <- sqrt(sum((compare2$Actual.x - compare2$Predicted.x)^2))
hrErr <- sqrt(sum((compare2$Actual.y - compare2$Predicted.y)^2))
lmErr
hrErr

hierarchicalPredict3 <- predictHierarchical(fds, "VOYAGE_CD", "SHOREX_REV", "TRADE", "WORLD VOYAGE")
worldCompare <- merge(lmPredict, hierarchicalPredict3, by="Voyage_cd")
worldCompare$Actual.x - worldCompare$Actual.y
worldCompare$Actual.x - worldCompare$Predicted.x
worldCompare$Actual.y - worldCompare$Predicted.y

hierarchicalPredict4 <- predictHierarchical(fds, "VOYAGE_CD", "SHOREX_REV", "TRADE", "CANADA NEW ENGLAND")
mexicoCompare <- merge(lmPredict, hierarchicalPredict4, by="Voyage_cd")
mexicoCompare$Actual.x - mexicoCompare$Actual.y
mexicoCompare <- mexicoCompare[-c(1,5),]
sqrt(sum((mexicoCompare$Actual.x - mexicoCompare$Predicted.x)^2))
sqrt(sum((mexicoCompare$Actual.y - mexicoCompare$Predicted.y)^2))
