#Q1 Part1==== 
library(horseshoe)
library(BoomSpikeSlab)
library(readr)
library(mvtnorm)
library(stringi)
library(ggplot2)
library(coda)
library(data.table)
library(rjags)
data1 <- read_delim("~/Google Drive/CodeProjects/R/prob1.csv", " ", escape_double = FALSE, trim_ws = TRUE)

updateD <- function(gammas, tau, slabConst, unitVec){
  gammaIs0 <- tau*(unitVec - gammas)
  D <- diag(gammaIs0 + (gammas*slabConst))
  D
}

updateBetaMean <- function(B, Xpy, sig2i){
  b <- B %*% (Xpy/sig2i)
  b
}
updateBetaVar <- function(XpX, sig2i, gammas, tau, slabConst, unitVec, R){
  D <- updateD(gammas, tau, slabConst, unitVec)
  Omega <- (D %*% R) %*% D
  B <- solve((XpX/sig2i) + solve(Omega))
  B
}
updatePriorVar <- function(gammas, tau, slabConst, unitVec, R){
  D <- updateD(gammas,tau,slabConst, unitVec)
  priorVar <- D %*% R %*% D
}
y <- as.matrix(data1[,1])
X <- as.matrix(data1[,2:11])
# X <- matrix(rnorm(300, 0, 1), nrow=60, ncol=5)
# y <- X[,4] + 1.2*X[,5] + rnorm(60, 0,1)
rows_cols <- dim(X)
XpX <- t(X)%*%X
Xpy <- t(X) %*% y
XpXinv <- solve(XpX)
mles <- XpXinv%*%Xpy
res <- y - X%*%mles
res2 <- t(res)%*%res
ses <- sqrt(diag(as.numeric(res2/(rows_cols[1] - rows_cols[2]) )*XpXinv))

sims <- 5000
bernProbs <- .5*rep(1,rows_cols[2])
unitVec <- rep(1,rows_cols[2])
tau <- .33*unitVec
c <- 10*unitVec
R <- diag(unitVec)
alphaHalf <- .5*(rows_cols[1])
priorMean <- t(rep(0,rows_cols[2]))
betasMat <- matrix(0, nrow=sims, ncol=rows_cols[2])
gammasMat <- matrix(0, nrow=sims, ncol=rows_cols[2])
sigma2 <- rep(1,sims)
gammas <- unitVec
betas <- mles
for(i in 1:sims){
  B <- updateBetaVar(XpX, sigma2[i], gammas, tau, c, unitVec, R)
  betas <- t(rmvnorm(1, t(updateBetaMean(B,Xpy, sigma2[i])), B))
  res <- y - X%*%betas
  deltaUpdateHalf <- .5*(t(res)%*%res )
  sigma2[i] <- 1/rgamma(1,alphaHalf, rate=1/deltaUpdateHalf)
  gammasCopy <- gammas
  for(j in 1:rows_cols[2]){
    gammasCopy[j] <- 1  
    B <- updatePriorVar(gammasCopy, tau, c, unitVec, R)
    a <- dmvnorm(t(betas), priorMean, B)*bernProbs[j]
    gammasCopy[j] <- 0
    B <- updatePriorVar(gammasCopy, tau, c, unitVec, R)
    b <- dmvnorm(t(betas), priorMean, B)*(1-bernProbs[j])
    probj <- a / (a + b)
    u <- runif(1)
    if(u < probj){
      gammas[j] <- 1
    }else{
      gammas[j] <- 0
    }
    gammasCopy <- gammas
  }
  betasMat[i, ] <- betas
  gammasMat[i, ] <- gammas
}

burnin <- .1*sims
gammasMat <- gammasMat[burnin:sims,]
pows <- 10^seq(0,rows_cols[2]-1)
models <- 0
for(i in 1:dim(modelMat)[1]){
  models[i] <- paste(as.character(gammasMat[i,]), collapse='')
}
models <- cbind(gammasMat, models)

modelFrequency <- as.data.frame(table(models[, rows_cols[2] + 1]))
modelFrequency[,3] <- modelFrequency$Freq/(sims-burnin)
colnames(modelFrequency) <- c("Model", "Freq", "Percentage")
modelFrequency <- modelFrequency[order(modelFrequency$Freq, decreasing = TRUE),]
modelFrequency[,1] <- as.character(modelFrequency[,1])

topModels <- head(modelFrequency)
ggplot(topModels, aes(x=Model,y=Percentage,fill=Model)) + 
  geom_bar(stat="identity", color="black") + 
  ylab("Percentage of Times Chosen") + 
  ggtitle("Posterior Probability of Model i") +
  theme_minimal() + 
  theme(text=element_text(size=10),axis.text.x = element_text(angle=45, hjust=1))

cat("LS Ests ", mles, "\n") 
cat(" T - statistics |t| = \n", abs(t(mles/ses)))
cat("Significant X's \n", which(abs(t(mles/ses)) > qt(.95, rows_cols[1] - rows_cols[2])))
head(modelFrequency[order(modelFrequency$Freq, decreasing = TRUE),])
HPDinterval(mcmc(betasMat))
summary((mcmc(betasMat)))
#Q1 Part 2====

bugdata <- list(y=as.numeric(y), X=X, N =rows_cols[1], J = rows_cols[2])
jmodel <- jags.model('/Users/dillonflannery-valadez/Google Drive/CodeProjects/R/final225.bug',
           data=bugdata, n.chains = 3, n.adapt = 100)
res <- coda.samples(jmodel, var=c('gamma', 'beta'), n.iter=1000)
results <- as.data.frame(res[[1]])

#Q1 Part 3====

spikeAndSlab <- lm.spike(y~X, niter=1000)
summary(spikeAndSlab)
horse <- horseshoe(y,X, method.tau = c('halfCauchy'), method.sigma = c("Jeffreys"),burn= 1000, nmc=5000)
HS.var.select(horse)
horse$BetaHat
horseDataFrame <- as.data.frame(t(horse$BetaSamples))
