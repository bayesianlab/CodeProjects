# Conditional Logit Maximization
getOb <- function(datframe, a, b){
  ob <- datframe[a:b, ]
  return(ob)
}

computeChoiceProb <- function(ob, params, nChoices){
  choice <- ob[ob[, 1]==1,]
  params <- as.matrix(params)
  num <- as.matrix(choice[, -1]) %*% params
  den <- log(sum(exp( as.matrix(ob[, -1]) %*% params)))
  return(den - num )
}

computeLikelihood <- function(datframe, params, nChoices){
  negLike <- 0 
  a <-  1
  b <- nChoices
  nr <- nrow(datframe) / nChoices
  for(r in 1:nr){
    ob <- getOb(datframe, a, b)
    a <- a + 4
    b <- b + 4
    negLike <- negLike + computeChoiceProb(ob, params, nChoices)
  }
  return(negLike)
}

clogitModel <- function(X, nChoices){
  initParams <- createParameters(0, X)
  ests <- optim(par=initParams, computeLikelihood, gr=NULL,
                datframe=X, nChoices=nChoices, 
                method="BFGS", control=list(abstol=1e-8, maxit=10000))
  return(ests$par)
}