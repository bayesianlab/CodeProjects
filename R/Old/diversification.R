superSigsqd <- .066875
slowSigsqd <- .013225
superSig <- sqrt(superSigsqd)
slowSig <- sqrt(slowSigsqd)
expRateSuper <- .175
expRateSlow <- .055

rho <- 1
weight1 <- .5
weight2 <- (1 - weight1)
# Variance of Portfolio Returns

varPortfolio <- function(weight1, weight2, sig1, sig2, rho){
  portV <- 0
  portV <- ((weight1^2) * sig1^2 + (weight2^2) * sig2^2 + 
               (2 * weight1 * weight2 * sig1 * sig2 * rho))
  return(portV)
}
source('/Users/dillonflannery-valadez/R projects/varPortfolio.R')



weight1 <- seq(0, 1, by = .025)
weight2 <- numeric(length(weight1))
for(i in 1:length(weight1)){
  weight2[i] <- (1-weight1[i])
}
expReturn <- numeric(length(weight1))
# Expected Returns for different portfolio weights
for(i in 1:length(weight1)){
  expReturn[i] <- expRateReturn(weight1[i], weight2[i], expRateSuper,
                                expRateSlow)
}
# Standard deviations for weights
stdP <- numeric(length(weight1))
for(i in 1:length(weight1)){
  stdP[i] <- sqrt(varPortfolio(weight1[i], 1 - weight1[i], 
                               sqrt(superSigsqd), sqrt(slowSigsqd), 
                               rho ))
}

matExpReturnsStdDev <- cbind(expReturn, stdP)
# Minimum expected Returns and Standard Deviations
minimum <- min(stdP)
indexofMin <- findMin(minimum, stdP)
cat( expReturn[indexofMin], stdP[indexofMin])

# Efficient Set
effstdP <- stdP[1:indexofMin]
effexpReturn <- expReturn[1:indexofMin]

# Plotting the standard deviations versus the expected returns
plot(stdP, expReturn, type = "l", ylab = "E[R]", 
     xlab = "Standard Deviation, Portfolio", main = "Optimal Portfolio")





