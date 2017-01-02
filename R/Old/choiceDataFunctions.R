# Conditional And Multinomial Choice Data Functions
createDummies <- function(X, nChoices, base){
  nobs <- nrow(X) / nChoices
  unos <- rep(1, nobs)
  dumMat  <- kronecker(unos, diag(nChoices))
  dumMat <- dumMat[, -base]
  return(cbind(X, dumMat))
}

interact <- function(X, altConstantColNum, interactions){
  interaction <- X[,altConstantColNum] * X[,interactions] 
  X <- X[,-altConstantColNum]
  X <- cbind(X, interaction)
  return(X)
}

createParameters <- function(estvec, X){
  if(length(estvec) < 2){
    params <- rep(0, ncol(X) -1) 
    return((params))
  }
  else{
    return(estvec, nrow=1)
  }
}

createConLogitData <- function(X, nChoices, basealt, altConstants){
  b4 <- ncol(X)
  X <- createDummies(X, nChoices, basealt)
  X <- interact(X, altConstants, b4+1)
  return(X)
}