library(readstata13)
library(base)
choiceData <- read.dta13("C:/Users/64063/Documents/R/Rprojects/choice.dta")
constant <- rep(1, nrow(choiceData))
choiceData <- cbind(constant, choiceData)


listToMat <- function(list, rows, cols){
  if(missing(rows)){
    outMat <- matrix(unlist(list), ncol=cols)
  }else if(missing(cols)){
    outMat <- matrix(unlist(list), nrow=rows)
  }else{
    outMat <- matrix(unlist(list), nrow=rows, ncol=cols)
  }
}

american <- matrix(nrow=nrow(choiceData), ncol=ncol(choiceData))
japanese <- matrix(nrow=nrow(choiceData), ncol=ncol(choiceData))
european <- matrix(nrow=nrow(choiceData), ncol=ncol(choiceData))
for(iden in 1:(nrow(choiceData)/3)){
  record <- choiceData[choiceData$id == iden,]
  if(record$choice[1] == 1){
    american[(3*iden -2):(3*iden), ] <-  listToMat(record, cols=ncol(choiceData)) 
  }
  if(record$choice[2] == 1){
    japanese[(3*iden -2):(3*iden), ] <-listToMat(record, cols =ncol(choiceData))
  }
  if(record$choice[3] == 1){
    european[(3*iden -2):(3*iden), ] <- listToMat(record, cols=ncol(choiceData))
  }
}

american <- american[complete.cases(american),]
japanese <- japanese[complete.cases(japanese),]
european <- european[complete.cases(european),]

ones <-  rep(1, nrow(choiceData)/3)
choices <- kronecker(ones, diag(3))
choices[,1] <- rep(0, nrow(choices))

neededCols <- c(1,3,4,8)




american <- subset(american, select=neededCols)
americanSex <- choices[1:nrow(american), ] * american[, 2]
americanIncome <- choices[1:nrow(american), ] * american[,3]
americanConstant <- choices[1:nrow(american),]
american <- cbind(americanConstant, americanSex, americanIncome, american)
american <- subset(american, select= c(1:9, 13))

japanese <- subset(japanese, select= neededCols)
japaneseSex <- choices[1:nrow(japanese), ] * japanese[,2]
japaneseIncome <- choices[1:nrow(japanese), ] * japanese[,3]
japaneseConstant <- choices[1:nrow(japanese),]
japanese <- cbind( japaneseConstant, japaneseSex, japaneseIncome, japanese)
japanese <- subset(japanese, select = c(1:9, 13))

european <- subset(european, select=neededCols)
europeanSex <- choices[1:nrow(european), ] * european[,2]
europeanIncome <- choices[1:nrow(european),] * european[,3]
europeanConstant <- choices[1:nrow(european), ]
european <- cbind(europeanConstant, europeanSex, europeanIncome, european)
european <- subset(european, select =c(1:9, 13))

choiceList <-list(american, japanese, european)


probabilityOfChoice <- function(alternativeVarying, alternativeConstant, betasVarying, betasConstant, choice){
  prodAltVarying <- t(betasVarying) %*% alternativeVarying
  prodConst <- t(betasConstant) %*% alternativeConstant[choice, ]
  den <- sum( exp( prodAltVarying + prodConst ) )
  num <- exp( (betasVarying %*% alternativeVarying[choice, ]) + prodConst  )
  return(log(num/den))
}

probabilityOfChoice2 <- function(record, betas, choice){
  betas <- as.matrix(betas)
  record <- subset(record, select= -c(1,4,7))
  num <-   exp( record[choice, ] %*% betas )
  den <-  sum(exp(record %*% betas ))
  return(log(num/den))
}

returnRecord <- function(data, startId, endId){
  record <- data[startId:endId, ]
  return(record)
}


logLikelihoodChoice <- function( choiceRecords, betas, selectedAlternative, alternatives){
  startId <- 1
  endId <-  alternatives
  like <- 0
  while(endId <= nrow(choiceRecords)){
    record <- returnRecord(choiceRecords, startId, endId)
    like <- like + probabilityOfChoice2(record, betas, selectedAlternative)
    startId <- startId + alternatives
    endId <- endId + alternatives
  } 
  return(like)
}

condLogitLikelihood <- function(dataList, alternatives, betas){
  like <- 0 
  for(alt in 1:alternatives){
    choiceMat <- as.matrix(dataList[[alt]])
    like <- like + logLikelihoodChoice(choiceMat, betas, alt, alternatives)
  }
  return(-like)
}





testX <- american[1:3, ]
testAltCons <- testX[, 1:9]
testAltVar <- as.matrix(testX[,10])
testBetasCons <- as.matrix(rep(1, ncol(testAltCons))) 
testBetaVar <- as.matrix(rep(1, ncol(testAltVar)))
testBetas <- rep(1, 7)

# probabilityOfChoice2(testX, testBetas, 1)

logLikelihoodChoice(american, testBetas, 1, 3)

typeof(choiceList[1])
a<- condLogitLikelihood(choiceList, 3, testBetas)
a
optim(par=testBetas, condLogitLikelihood, alternatives=3, dataList=choiceList)

# set.seed(1)
# m <- matrix(rnorm(20), nrow = 4)
# m
# by(m, m[1:2,], sum)
