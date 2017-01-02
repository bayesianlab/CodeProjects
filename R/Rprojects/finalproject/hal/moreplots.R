library(base)
library(plyr)
# Closer study of age and spending reveals over 80% of spending is done by ages 50-78

fd <- finaldat
fd$PAX_AGE <- cut(finaldat$PAX_AGE, 20, ordered_result = TRUE)
levels(fd$PAX_AGE)[1] <- "(0,10.2]"
tabAge <- table(fd$PAX_AGE)
percentAge <- as.data.frame(tabAge/nrow(fd))
ggplot(percentAge, aes(percentAge$Var1, percentAge$Freq, fill=percentAge$Var1)) +
  geom_bar(stat="identity") +
  labs(x="Age", y = "Percent", fill="Age")
ageLevels <- levels(fd$PAX_AGE)
ageBreaks <- length(ageLevels)

totalDailySpending <- sum(fd$onBoardDailySpend)
ageSums <- 0
for(i in 1:ageBreaks){
  ageSums[i] <- sum(fd[fd$PAX_AGE == ageLevels[i], "onBoardDailySpend"])/totalDailySpending
}
percentAge <- cbind(percentAge, ageSums)
bigSpend <- sum(percentAge[c(10:13), "ageSums"])
notBigSpend <- sum(percentAge[-c(10:13), "ageSums"])
oldYoungSpenders <- data.frame(matrix(c(c("50-72", "Not 50-72"), bigSpend, notBigSpend), nrow=2))
oldYoungSpenders$X2 <- as.numeric(as.character(oldYoungSpenders$X2))
ggplot(oldYoungSpenders, aes(X1, X2,fill=X1)) + geom_bar(stat="identity", width = .4) +
  labs(x="Age", y="Percentage On Board Spending", fill="Age")

# Closer study of cruiselength and totalspending
crlSpend <- tapply(fd$totalSpent, fd$CRUISELENGTH, mean)
crlSpend <- data.frame(matrix(cbind(names(crlSpend), crlSpend), ncol=2))
crlSpend$X1 <- factor(as.numeric(as.character(crlSpend$X1)), ordered=TRUE)
crlSpend$X2 <- as.numeric(as.character(crlSpend$X2))

ggplot(crlSpend, aes(X1, y=value)) + 
  geom_point(aes(y=X2)) + 
  geom_point(aes(y=V3), color="blue") +
  theme(legend.position="none") +
  labs(x="Cruise Length", y= "Avg. Amount Spent")
table(fd$CRUISELENGTH)
2*5900
c(38*776, 16*1620, 8*3000, 11800)
for(i in 1:nrow(crlSpend)){
  possibleCrs <- 116/as.numeric(as.character(crlSpend[i,1])) 
  crlSpend[i, 3] <- possibleCrs * crlSpend[i,2]
}

# Fixing up loyalty
finaldat$PAX_LOYALTY <- mapvalues(finaldat$PAX_LOYALTY, from= c("0S", "1S    ", "2S    ", "3S    ",
                                  "4S    ", "5S    "), to = c("0Star", "1Star", "2Star", "3Star", 
                                                              "4Star", "5Star"))
finaldat$PAX_LOYALTY <- combineLevels(finaldat$PAX_LOYALTY,
                                      c("1N    ", "288925449", "FT    ",
                                     "NH    ", "P1    "), newLabel=c("Other"))

levels(finaldat$PAX_LOYALTY)
finaldat$PAX_LOYALTY[finaldat$PAX_LOYALTY ==""] <- NA
table(finaldat$PAX_LOYALTY)


# Closer look at loyalty and spending
loyalty <- aggregate(finaldat$onBoardDailySpend ~ finaldat$PAX_LOYALTY , data=finaldat, mean)
colnames(loyalty) <- c("Stars", "AvgSpend")
ggplot(loyalty, aes(x=Stars, AvgSpend, fill=Stars)) + geom_bar(stat="identity") +
  labs(x="Loyalty", y="Avg. Spending", fill="Loyalty")

# Break down of spending 
revList <- numeric()
rowName <- 0
for(i in 4:11)
{
  revList[[i-3]] <- sum(finaldat[,i])
  rowName[[i-3]] <- colnames(finaldat)[i]
}

totals <- data.frame(cbind(rowName, revList))
totals$revList <- as.numeric(as.character(totals$revList))
totals <- totals[order(totals$revList),]
ggplot(totals, aes(rowName, revList, fill=rowName)) + geom_bar(stat="identity")
                                  


