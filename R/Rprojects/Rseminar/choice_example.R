library(readstata13)
choiceData <- read.dta13("~/R projects/R Seminar/choice.dta")
testData <- choiceData[1:3,]
testX <- t(matrix(cbind(testData$sex, testData$income, testData$dealer), nrow=3))
testBetas <- matrix(rep(1,6), nrow=3)
testBetas <- cbind(c(0,0,0), testBetas)

for(iden in 1:(nrow(choiceData)/3)){
  record <- choiceData[choiceData$id == iden,]
  american <- matrix(nrow=nrow(choiceData), ncol=ncol(choiceData))
  c <- 0
  if(record$choice[1] == 1){
    c <- c +1
  }
 
}
c

probabilityOfChoice <- function(choice, individualCharacteristics, betas){
  restrictedChoiceSet <- betas[ , -choice]
  sumRestrictedChoiceSet <- sum(t(restrictedChoiceSet) %*% individualCharacteristics)
  num <- exp( t(betas[, choice]) %*% individualCharacteristics)
  den <- 1 + sumRestrictedChoiceSet
  return(num/den)
}



logLikelihoodMultLogit <- function(y, x, betas){
  probOfChoice <- apply(x, 2, probabilityOfChoice, choice=1, betas=betas)
  print(a)
}




