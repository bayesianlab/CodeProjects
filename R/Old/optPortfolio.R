
# Deriving the Efficient Set 
pstate <- c(.15, .65, .20)
rateA  <- c(.06, .07, .11)
rateB  <- c(-.20, .13, .33)
expRateA <- 0
expRateB <- 0
varA <- 0
varB <- 0
for(i in 1:length(pstate)){
  expRateA <- expRateA + pstate[i]* rateA[i]
  expRateB <- expRateB + pstate[i]* rateB[i]
}
for(i in 1:length(pstate)){
  varA <- varA + pstate[i]*(rateA[i] - expRateA)^2
  varB <- varB + pstate[i]*(rateB[i] - expRateB)^2
}
stdA <- sqrt(varA)
stdB <- sqrt(varB)

# For variance portfolio function, see diversification.R...
source('/Users/dillonflannery-valadez/R projects/varPortfolio.R')
covarianceAB <- pStateCovariance(pstate, rateA, rateB, expRateA, expRateB)
rho <- covarianceAB/(stdA*stdB)

# Expected rates of return and standard deviations...
cat(" Rate A  ", expRateA, "  Std. A  ", stdA, "\n","Rate B  ", expRateB, 
    "  Std. B  ", stdB)

# Finding the optimal portfolio...
weight1 <- seq(0, 1, by = .025)
weight2 <- numeric(length(weight1))
for(i in 1:length(weight1)){
  weight2[i] <- (1-weight1[i])
}
expReturn <- numeric(length(weight1))

# Expected Returns for different portfolio weights
for(i in 1:length(weight1)){
  expReturn[i] <- expRateReturn(weight1[i], weight2[i], expRateA, expRateB)
}

# Standard deviations for weights
stdP <- numeric(length(weight1))
for(i in 1:length(weight1)){
  stdP[i] <- sqrt(varPortfolio(weight1[i], 1 - weight1[i], stdA, stdB, -.5 ))
}
stdReturnMat <- as.matrix(cbind(stdP, expReturn))

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
lines(effstdP, effexpReturn, col = "red")
points(stdP[indexofMin], expReturn[indexofMin], pch = 19)
text(stdP[41], expReturn[41], label ="Minimum Variance Point", 
     pos = 4, cex = .9)
text(stdP[floor(indexofMin/2)], expReturn[floor(indexofMin/2)], 
     label= "Efficient Set", pos = 2)





