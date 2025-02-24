library(ggplot2)
library(coda)
# Q4 ====
setwd("~/Google Drive/CodeProjects/R/")
D <- as.data.frame(read.table("coal.txt", header=TRUE))
rc <- dim()
D <- cbind(D,seq(1,rc[1], by=1))
colnames(D)[3] <- "index"
ggplot(data=D, aes(x=D$year, y=D$disasters)) + geom_point() +xlab("Year") + ylab("Disasters")
y <- D$disasters
N <- length(y)
R <- 10000
posterior <- data.frame(matrix(0, nrow=R, ncol=3))
cumulativeSumY <- cumsum(y)
thetaRange <- 1:N-1
theta <- sample(thetaRange, 1, replace = TRUE)
alpha <- 3
bn <- 1000
for(i in 1:R){
  u1 <- sum(y[1:theta]) + 3
  v1 <- (theta + alpha^(-1))^(-1)
  u2 <- sum(y[(theta+1):N]) + 3
  v2 <- (N - theta + alpha^(-1))^(-1)
  lam1 <- rgamma(1, u1, scale=v1)
  lam2 <- rgamma(1, u2, scale=v2)
  unnormalized <- (lam1/lam2)^(cumulativeSumY)*exp(-thetaRange*(lam1-lam2))
  normalized <- unnormalized/sum(unnormalized)
  theta <- which(runif(1) < cumsum(normalized))[1]
  posterior[i,] <- c(lam1, lam2, theta)  
}
posterior <- posterior[bn:R,]
par(mfrow=c(1,3))
hist(posterior[,1], main="Lambda 1")
hist(posterior[,2], main = "Lambda 2")
hist(posterior[,3], main = "Theta")
par(mfrow=c(3,1))
plot(posterior[,1], type="l", main="Lambda 1")
plot(posterior[,2], type="l", main="Lambda 2")
plot(posterior[,3], type="l", main="Theta")
par(mfrow=c(1,3))
plot(density(posterior[,1]), main="Lambda 1")
plot(density(posterior[,2]), main="Lambda 2")
plot(density(posterior[,3]), main="Theta")
par(mfrow=c(1,3))
summary(posterior)
boxplot(posterior[,1], main="Lambda 1")
boxplot(posterior[,2], main="Lambda 2")
boxplot(posterior[,3], main="Theta")
HPDinterval(mcmc(posterior))
summary(posterior)
par(mfrow=c(1,1))
plot(y)

# Q1 a ====
set.seed(6)
par(mfrow=c(1,1))

mixtured <- function(delta,mu1,sigma1, mu2,sigma2, N){
  delta*rnorm(N, mu1, sigma1) + (1-delta)*rnorm(N,mu2,sigma2)
}

loglike <- function(delta, mu1, mu2, sigma1, sigma2, x){
  if( (0 < delta) && (delta <= 1)){
    lambda <- delta*mu1 + (1-delta)*mu2
    gamma <- sqrt((delta^2)*sigma1^2 + ((1-delta)^2)*sigma2^2)
    C <- -length(x)*log(sqrt(2*pi*gamma^2))
    Mah <- (t(x-lambda)%*%(x-lambda))/(2*gamma^2)
    L <- C - Mah 
    L    
  }else{
    L <- -Inf
    L
  }
}

mu1 <- 7
mu2 <- 10
sigma1 <- sigma2 <- .5
M <- mixtured(.7, 7, .5, 10, .5, 200)
mdf <- as.data.frame(M, colnames="Mix")
ggplot(data=mdf, aes(x=M, colour='b')) + geom_histogram(aes(y=..count..))+ theme(legend.position="none") +
  xlab('200 Obs. From Mixture Distribution')+ylab('Frequency')
hist(M, breaks = 20)


# Q1 b ====
Runs <- 10000
burn <- floor(.1*Runs)
chains <- 3
mhsample <- matrix(0, nrow=Runs, ncol=chains)
mhsample[1] <- runif(1, 0, 1)
for(c in 1:chains){
  delta <- runif(1)
  for(i in 2:Runs){
    loglike_t <- loglike(delta, mu1, mu2, sigma1, sigma2, M)
    prop_tp1 <- runif(1)
    loglike_tp1 <- loglike(prop_tp1, mu1, mu2, sigma1, sigma2, M)
    num <-  loglike_tp1 + log(dunif(mhsample[i-1]))
    den <- loglike_t + log(dunif(prop_tp1))
    a <- min(0, num-den)
    u <- log(runif(1))
    if(u < a){
      mhsample[i, c] <- prop_tp1
      delta <- prop_tp1
    }else{
      mhsample[i, c] <- mhsample[i-1, c]
    }
  }
}
mhsample <- as.data.frame(mhsample[burn:Runs,])
mcobj <- as.mcmc.list(as.mcmc(mhsample))
plot(mcobj)
summary(mcobj)


# Q1 c====
Runs <- 10000
burn <- floor(.1*Runs)
chains <- 3
mhsample <- matrix(0, nrow=Runs, ncol=chains)
mhsample[1] <- runif(1, 0, 1)
for(c in 1:chains){
  delta <- runif(1)
  for(i in 2:Runs){
    logfprevious <- loglike(delta, mu1, mu2, sigma1, sigma2, M)
    badproposal <- 1
    while(badproposal == 1){
      proposal <- delta + runif(1,-1,1)
      if( (proposal < 0) || (proposal > 1) ){
        badproposal <- 1
      }
      else{
        badproposal <- 0
      }
    }
    logfproposal <- loglike(proposal, mu1, mu2, sigma1, sigma2, M)
    num <-  logfproposal + dunif(delta, log=TRUE)
    den <- logfprevious + dunif(proposal, log=TRUE)
    a <- min(0, num-den)
    u <- log(runif(1))
    if(u < a){
      mhsample[i, c] <- proposal  
      delta <- proposal
    }else{
      mhsample[i, c] <- delta
    }
  }
}
mhsample <- mhsample[burn:Runs,]
mcobj <- as.mcmc(mhsample)
plot(mcobj)
summary(mcobj)


# Q1 d====
Runs <- 10000
burn <- floor(.1*Runs)
chains <- 3
mhsample <- matrix(0, nrow=Runs, ncol=chains)
mhsample[1] <- runif(1, 0, 1)
for(c in 1:chains){
  delta <- runif(1)
  for(i in 2:Runs){
    logfprevious <- loglike(delta, mu1, mu2, sigma1, sigma2, M)
    badproposal <- 1
    while(badproposal == 1){
      U <- log(delta/(1-delta))
      Ustar <- U + runif(1,-1,1)
      proposal <- exp(Ustar)/(1+exp(Ustar))
      if( (proposal < 0) || (proposal > 1) ){
        badproposal <- 1
      }
      else{
        badproposal <- 0
      }
    }
    logfproposal <- loglike(proposal, mu1, mu2, sigma1, sigma2, M)
    num <-  logfproposal + dunif(delta, log=TRUE)
    den <- logfprevious + dunif(proposal,log=TRUE)
    a <- min(0, num-den)
    u <- log(runif(1))
    if(u < a){
      mhsample[i, c] <- proposal 
      delta <- proposal
    }else{
      mhsample[i, c] <- delta
    }
  }
}
mhsample <- mhsample[burn:Runs,]
mcobj <- as.mcmc(mhsample)
plot(mcobj)
summary(mcobj)


# Q2 a====  
Runs <- 10000
burn <- floor(.1*Runs)
chains <- 3
mhsample <- matrix(0, nrow=Runs, ncol=chains)
mhsample[1] <- runif(1, 0, 1)
init <- c(0,7,15)
Mu <- .7*mu1 + .3*mu2
Sig <- sqrt((.7^2)*sigma1^2 + (.3^2)*sigma2^2)
propSd <- sqrt(.01)
for(c in 1:chains){
  previous <- init[c]
  mhsample[1,c] <- init[c]
  cat("Iteration ", c)
  for(i in 2:Runs){
    logfprevious <- dnorm(previous, Mu, Sig, log=TRUE)
    proposal <- rnorm(1,previous, propSd)
    logfproposal <- dnorm(proposal, Mu,Sig, log=TRUE)
    num <-  logfproposal + dnorm(previous, proposal, propSd, log=TRUE)
    den <- logfprevious + dnorm(proposal, previous, propSd, log=TRUE)
    a <- min(0, num-den)
    u <- log(runif(1))
    if(u < a){
      mhsample[i, c] <- proposal  
      previous <- proposal
    }else{
      mhsample[i, c] <- previous
    }
  }
}
mcobj <- as.mcmc(mhsample)
plot(mcobj)
summary(mcobj)

#Q2 b====
Runs <- 1000
burn <- floor(.1*Runs)
chains <- 3
mhsample <- matrix(0, nrow=Runs, ncol=chains)
mhsample[1] <- runif(1, 0, 1)
init <- c(0,7,15)
Mu <- .7*mu1 + .3*mu2
Sig <- sqrt((.7^2)*sigma1^2 + (.3^2)*sigma2^2)
propSd <- 1
for(c in 1:chains){
  previous <- init[c]
  cat("Iteration ", c)
  for(i in 2:Runs){
    logfprevious <- dnorm(previous, Mu, Sig, log=TRUE)
    proposal <- rnorm(1,previous, propSd)
    logfproposal <- dnorm(proposal, Mu,Sig, log=TRUE)
    num <-  logfproposal + dnorm(previous, proposal, propSd, log=TRUE)
    den <- logfprevious + dnorm(proposal, previous, propSd, log=TRUE)
    a <- min(0, num-den)
    u <- log(runif(1))
    if(u < a){
      mhsample[i, c] <- proposal  
      previous <- proposal
    }else{
      mhsample[i, c] <- previous
    }
  }
}
mhsample <- mhsample[burn:Runs,]
mcobj <- as.mcmc(mhsample)
plot(mcobj)
summary(mcobj)
