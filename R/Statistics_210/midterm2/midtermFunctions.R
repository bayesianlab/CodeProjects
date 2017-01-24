akaikeInfo <- function(linMod){
  p  <- length(linMod$coefficients)
  ssr <- sum(linMod$residuals^2)
  n <- length(linMod$residuals)
  sigmaSqd <- ssr / (n - p)
  aic <- log(sigmaSqd) + ( (n+p) / (n-p-2) )
  aic
}

bayesianInfo <- function(linMod){
  p  <- length(linMod$coefficients) 
  ssr <- sum(linMod$residuals^2)
  n <- length(linMod$residuals)
  sigmaSqd <- ssr / (n - p)
  bic <- log(sigmaSqd) + (p*log(n) /n)
  bic
}

concatNames <- function(names, selection){
  indxs <- which(selection ==1)
  char <- ""
  for(i in 1:length(indxs)){
    if(i == 1){
      char <- paste(char, as.character(names[indxs[i]]))  
    }
    else{
      char <- paste(char,  paste(" ",as.character(names[indxs[i]])), sep=",")  
    }
  }
  char
}

orderAscending <- function(models){
  rowSums <- rowSums(models)
  newModels <- as.data.frame(cbind(models,rowSums))
  orderedModel <- newModels[order(newModels$rowSums), ]
  r_c <- dim(orderedModel)
  orderedModel <- orderedModel[, -r_c[2]]
  orderedModel
}

orderDescending <- function(models){
  rowSums <- rowSums(models)
  newModels <- as.data.frame(cbind(models,rowSums))
  orderedModel <- newModels[order(-newModels$rowSums), ]
  r_c <- dim(orderedModel)
  orderedModel <- orderedModel[, -r_c[2]]
  orderedModel
}

loopOverModels <- function(dependent, covariates, method){
  size <- dim(covariates)
  models <- bincombinations(size[2])
  models <- models[,8:1]
  models <- orderAscending(models)  
  r_c <- dim(models)
  names <- colnames(covariates)
  stoResults <- as.data.frame(matrix(0, nrow=r_c[1], ncol=2))
  base <- lm(dependent~1)
  stoResults[1,1] <- "Null"
  stoResults[1,2] <- method(base)
  for(i in 2:r_c[1]){
    row <- models[i, 1:r_c[2]]
    X <- covariates[,which(row==1)]
    dm <- as.data.frame(cbind(dependent,X))
    mod <- lm(data=dm, dependent~.)
    aic <- method(mod)
    rowNames <- concatNames(names, row)
    stoResults[i,1] <- rowNames
    stoResults[i,2] <- aic
  }
  stoResults
}

computeAkaikeBayesianInfo <- function(dependent, covariates){
  size <- dim(covariates)
  models <- bincombinations(size[2])
  models <- models[,8:1]
  models <- orderAscending(models)  
  r_c <- dim(models)
  names <- colnames(covariates)
  stoResults <- as.data.frame(matrix(0, nrow=r_c[1], ncol=5))
  base <- lm(dependent~1)
  stoResults[1, 1] <- "Null"
  stoResults[1, 2] <- akaikeInfo(base)
  stoResults[1, 3] <- bayesianInfo(base)
  stoResults[1,4] <- AIC(base)
  stoResults[1,5] <- BIC(base)
  for(i in 2:r_c[1]){
    row <- models[i, 1:r_c[2]]
    X <- covariates[,which(row==1)]
    dm <- as.data.frame(cbind(dependent,X))
    mod <- lm(data=dm, dependent~.)
    aic <- akaikeInfo(mod)
    bic <- bayesianInfo(mod)
    rowNames <- concatNames(names, row)
    stoResults[i,1] <- rowNames
    stoResults[i,2] <- aic
    stoResults[i,3] <- bic
    stoResults[i,4] <- AIC(mod)
    stoResults[i,5] <- BIC(mod)
  }
  colnames(stoResults) <- c("Model", "AIC","BIC","R-AIC","R-BIC")
  stoResults
}

variableSelection <- function(dependent, covariates, method){
  if(method=="AIC"){
    results <- loopOverModels(dependent, covariates, method=akaikeInfo)
  }
  else{
    results <- loopOverModels(dependent, covariates, method=bayesianInfo)
  }
    results
}

forwardSelection <- function(dependent, covariates){
  size <- dim(covariates)
  linModBest <- lm(dependent~1)
  currentSelection <- rep(0,size[2])
  iterations <- choose(size[2]+1,2) + size[2]
  results <- as.data.frame(matrix(NA, nrow=iterations, ncol=4))
  results[1, 1:2] <- "Null Model"
  results[1, 3] <- "AIC"
  results[1, 4] <- "BIC"
  modelString <- "Model = "
  rowCount <- 1
  paramCount <- 1
  selectedVars <- covariates[, which(currentSelection==1)]
  for(j in 1:size[2]){
    size2 <- dim(covariates)  
    names <- colnames(covariates)
    Fstat <- numeric(size[2])
    paramCount <- paramCount + 1
    for(i in 1:size2[2]){
      Fcrit <- qf(.85, 1, size[1] - paramCount)
      rowCount <- rowCount + 1
      linModNew <- prepareModel(selectedVars, covariates[,i], dependent)
      Fstat[i] <- computeF(linModNew, linModBest)
      results[rowCount, 1] <- paste("Added", names[i])
      results[rowCount, 2] <- Fstat[i]
      results[rowCount, 3] <- Fcrit
      results[rowCount, 3] <- akaikeInfo(linModNew)
      results[rowCount, 4] <- bayesianInfo(linModNew)
      cat(sprintf("fstat %f  it %i\n", Fstat[i], i))
    }
    if(max(Fstat) > Fcrit){
      maxIndx <- which.max(Fstat)
      currentSelection[maxIndx] <- 1
      selectedVars <- cbind(selectedVars, covariates[maxIndx])
      tempData <- as.data.frame(cbind(dependent, selectedVars))
      linModBest <- lm(data=tempData, dependent~. )
      covariates <- as.data.frame(covariates[, -maxIndx])
      rowCount <- rowCount + 1
      tempString <- names[maxIndx]
      modelString <-paste(modelString, tempString, " + ", sep="")
      results[rowCount, 1:4] <- substr(modelString, 1, nchar(modelString)-2)
    }
    else{
      break
    }
  }
  cat(substr(modelString, 1, nchar(modelString)-2))
  results[1:rowCount, ]
}

backwardSelection <- function(dependent, covariates){
  size <- dim(covariates)
  iterations <- choose(size[2]+1,2) + size[2]
  results <- as.data.frame(matrix(NA, nrow=iterations, ncol=4))
  results[1, 1:2] <- "Full Model"
  results[1, 3] <- "AIC"
  results[1, 4] <- "BIC"
  modelString <- "Model = "
  rowCount <- 1
  paramCount <- 0
  currentSelection <- rep(1, size[2])
  selectedVars <- covariates[, which(currentSelection==1)]
  tempData <- as.data.frame(cbind(dependent, selectedVars))
  linModBest <- lm(data = tempData, dependent~.)
  for(j in 1:size[2]){
    size2 <- dim(covariates)
    names <- colnames(covariates)
    Fstat <- numeric(size2[2])
    paramCount <- paramCount + 1
    for(i in 1:size2[2]){
      rowCount <- rowCount + 1
      Fcrit <- qf(.85, 1, size[1] - (size[2]-paramCount))
      tempData <- as.data.frame(cbind(dependent, covariates[,-i]))
      linModNew <- lm(data=tempData, dependent~.)
      Fstat[i] <- computeF(linModBest, linModNew)
      results[rowCount, 1] <- paste("Dropped", names[i])
      results[rowCount, 2] <- Fstat[i]
      results[rowCount, 3] <- akaikeInfo(linModNew)
      results[rowCount, 4] <- bayesianInfo(linModNew)
      cat(sprintf("fstat, crit %f, %f  it %i\n ", Fstat[i], Fcrit, i))
    }
    if( min(Fstat) < Fcrit ){
      minIndx <- which.min(Fstat)
      currentSelection[minIndx] <- 0
      selectedVars <- covariates[, which(currentSelection == 1)]
      currentSelection <- currentSelection[-minIndx]
      tempData <- as.data.frame(cbind(dependent, selectedVars))
      linModBest <- lm(data=tempData, dependent~.)
      covariates <- covariates[, -minIndx]
      rowCount <- rowCount + 1
      results[rowCount, 1:4] <- paste(names[minIndx], "not significant")
      cat("\n")
    }
    else{
      rowCount <- rowCount + 1
      results[rowCount, 1:4] <- "No drops possible"
      break
    }
  }
  cat(paste("Model = ", paste(colnames(covariates), collapse=" + ")))
  cat("\n")
  list(results[1:rowCount, ], covariates)
}

computeF <- function(linModNew, linModBest){
  residsBest <- linModBest$residuals
  residsNew <- linModNew$residuals
  estimatedParameters <- length(linModNew$coefficients)
  denDf <- length(linModNew$residuals) - estimatedParameters
  sseBest <- sum(residsBest^2)
  sseNew <- sum(residsNew^2)
  F <- (sseBest - sseNew)/ (sseNew/denDf)
  F
}

prepareModel <- function(selection, newVar, dependent){
  X <- cbind(selection, newVar)
  tempData <- as.data.frame(cbind(dependent, X))
  linModNew <- lm(data=tempData, dependent~.)
  linModNew
}

forwardBackwardSelection <- function(dependent, covariates){
  size <- dim(covariates)
  linModBest <- lm(dependent~1)
  iterations <- choose(size[2]+1,2) + size[2]
  modelString <- "Model = "
  rowCount <- 1
  paramCount <- 1
  innerLoopCount <- 0
  selectedVars <- covariates[, which(rep(0,size[2])==1)]
  while(TRUE){
    size2 <- dim(covariates)
    if(size2[2] == 0){
      break
    }
    names <- colnames(covariates)
    Fstat <- numeric(size2[2])
    paramCount <- paramCount + 1
    innerLoopCount <- innerLoopCount + 1
    cat(sprintf("Backwards steps %i\n", innerLoopCount))
    for(i in 1:size2[2]){
      Fcrit <- qf(.85, 1, size[1] - paramCount)
      rowCount <- rowCount + 1
      X <- as.data.frame(cbind(selectedVars, covariates[, i]))
      xDim <- dim(X)
      colnames(X)[xDim[2]] <- names[i]
      br <- nestedBackwardSelector(dependent, X)
      backwardsResults <- br[[1]]
      backwardsResultsCheck <- dim(backwardsResults)[2]
      if(backwardsResultsCheck == 0 ){
        covariates <- covariates[, -i]
        break
      }
        tempData <- as.data.frame(cbind(dependent, backwardsResults))
        linModNew <- lm(data=tempData, dependent~.)
        Fstat[i] <- computeF(linModNew, linModBest)
        cat(paste("Current Model = ", paste(colnames(backwardsResults), collapse=" + ")))
        cat("\n\n")
    }
    if(max(Fstat) > Fcrit){
      maxIndx <- which.max(Fstat)
      selectedVars <- cbind(selectedVars, covariates[maxIndx])
      tempData <- as.data.frame(cbind(dependent, selectedVars))
      linModBest <- lm(data=tempData, dependent~. )
      covariates <- as.data.frame(covariates[, -maxIndx])
      rowCount <- rowCount + 1
      cat(paste("Best Model = ", paste(colnames(selectedVars), collapse = " + ")))
      cat("\n\n")
    }
    else{
      names <- colnames(backwardsResults)
      cat(paste("\nBest Model Overall = ", paste(names, collapse = " + ")))
      break
    }
  }
}

nestedBackwardSelector <- function(dependent, covariates){
  size <- dim(covariates)
  iterations <- choose(size[2]+1,2) + size[2]
  rowCount <- 1
  paramCount <- 0
  currentSelection <- rep(1, size[2])
  tempData <- as.data.frame(cbind(dependent, covariates[, which(currentSelection==1)]))
  linModBest <- lm(data = tempData, dependent~.)
  for(j in 1:size[2]){
    size2 <- dim(covariates)
    names <- colnames(covariates)
    Fstat <- numeric(size2[2])
    paramCount <- paramCount + 1
    for(i in 1:size2[2]){
      rowCount <- rowCount + 1
      Fcrit <- qf(.85, 1, size[1] - (size[2]-paramCount))
      tempData <- as.data.frame(cbind(dependent, covariates[,-i]))
      linModNew <- lm(data=tempData, dependent~.)
      Fstat[i] <- computeF(linModBest, linModNew)
      cat(sprintf("[fstat, fcrit] = [%f, %f]  iteration %i. fstat calculated w/%s dropped.\n",
                  Fstat[i], Fcrit, i,  names[i]))
    }
    if( min(Fstat) < Fcrit ){
      minIndx <- which.min(Fstat)
      currentSelection[minIndx] <- 0
      covariates <- as.data.frame(covariates[, which(currentSelection == 1)])
      currentSelection <- currentSelection[-minIndx]
      tempData <- as.data.frame(cbind(dependent, covariates))
      linModBest <- lm(data=tempData, dependent~.)
      rowCount <- rowCount + 1
      cat(paste("Dropped", names[minIndx]))
      cat("\n")
      if(dim(covariates)[2] == 0){
        return(list(covariates, minIndx))
      }
      list(covariates, minIndx)
    }
    else{
      cat("All variables in model significant.\n")
      return(list(covariates, 0))
    }
  }
}


