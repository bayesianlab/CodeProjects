#Q1 Part1==== 
library(horseshoe)
library(BoomSpikeSlab)
library(readr)
library(mvtnorm)
library(stringi)
library(ggplot2)
library(gridExtra)
library(grid)
library(coda)
library(data.table)
library(rjags)
library(truncnorm)
library(SuppDists)
dev.off()
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
for(i in 1:dim(gammasMat)[1]){
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
summary(res)
plot(res)

#Q1 Part 3====

spikeAndSlab <- lm.spike(y~X, niter=1000)
summary(spikeAndSlab)

#Q1 Part 4====

horse <- horseshoe(y,X, method.tau = c('halfCauchy'), method.sigma = c("Jeffreys"),burn= 1000, nmc=5000)
HS.var.select(horse)
horse$BetaHat
horseDataFrame <- as.data.frame(t(horse$BetaSamples))

#Q2 Part 1====
updateVar <- function(priorVarInv, X){
  B <- solve(priorVarInv + (t(X)%*%X))
  B
}
updateBeta <- function(X,z, updateVar, betaPrior, priorVarInv){
  b <- updateVar %*% ( priorVarInv %*% betaPrior + (t(X)%*%z) )
  b
}
drawZ <- function(yi, mui, vi){
  if(yi > 0){
    znew <- rtruncnorm(1, 0, Inf, mui, vi)
  }else{
    znew <- rtruncnorm(1, -Inf, 0, mui, vi)
  }
}
gibbsAlbertChib <- function(y, X, sims){
  rc <- dim(X)
  betaPrior <- rep(0, rc[2])
  BPrior <- 10*diag(rc[2])
  priorVarInv <- solve(BPrior)
  znew <- rep(0, rc[1])
  betaMat <- matrix(0, nrow=sims, ncol= rc[2])
  for(i in 1:sims){
    Bupdate <- updateVar(priorVarInv, X)
    bnew <- t(rmvnorm(1, updateBeta(X, znew, Bupdate, betaPrior, priorVarInv), Bupdate))
    for(j in 1:rc[1]){
      znew[j] <- drawZ(y[j], X[j,]%*%bnew, 1)
    }
    betaMat[i, ] <- t(bnew)
  }
  betaMat
}


prostatedata <- read_csv("~/Google Drive/CodeProjects/R/prostatedata.csv")
race <- as.numeric(prostatedata$Race)
prostatedata <- prostatedata[-which(is.na(race)), ]
y <- prostatedata$CP
X <- cbind(prostatedata$PSA, prostatedata$GS)
rc <- dim(X)
lsests <- lm(y~X)[[1]]
sims <- 5000
betaAC <- as.data.frame(gibbsAlbertChib(y,X,sims))
betaAC <- betaAC[floor(.1*sims):sims, ]
plot(mcmc(betaAC))
summary(mcmc(betaAC))
plotAC1 <- qplot(betaAC$V1, geom="histogram", fill=I("blue"), col=I("black"), 
      alpha= I(.75), bins=40, xlab="beta 1") 
plotAC2 <- qplot(betaAC$V2, geom="histogram", bins=40, fill=I("blue"), col=I("black"),
      alpha=I(.75), xlab="beta 2" ) 

#Q2 Part 2====
gibbsDataAug <- function(y, X, sims){
  rc <- dim(X)
  nobs <- rc[1]
  betaPrior <- rep(0, rc[2])
  BPrior <- 10*diag(rc[2])
  priorVarInv <- solve(BPrior)
  V <- updateVar(priorVarInv, X)
  S <- V %*% t(X)
  betaMat <- matrix(0, nrow=sims, ncol=rc[2])
  h <- matrix(0, nrow=nobs, ncol=1)
  w <- matrix(0, nrow=nobs, ncol=1)
  v <- matrix(0, nrow=nobs, ncol=1)
  z <- matrix(0, nrow=nobs, ncol=1)
  for(i in 1:nobs){
    h[i] <- X[i,] %*% S[,i]
    w[i] <- h[i]/(1- h[i])
    v[i] <- w[i] + 1
  }
  for(i in 1:nobs){
    if(y[i] > 0 ){
      z[i] <- rtruncnorm(1,0,Inf,0,1)
    }else{
      z[i] <- rtruncnorm(1,-Inf, 0,0,1)
    }
  }
  B <- S %*% z
  for(i in 1:sims){
    for(j in 1:nobs){
      zold <- z[j]
      m <- X[j,] %*% B
      m <- m - w[j] * (z[j] - m )
      z[j] <- drawZ(y[j], m, v[j])
      B <- B + (z[j] - zold) * S[,j]
    }
    betaMat[i,] <- t(rmvnorm(1, B, V))
  }
  betaMat
}

betaAug <- as.data.frame(gibbsDataAug(y, X,sims))
betaAug <- betaAug[floor(.1*sims), ]
plot(mcmc(betaAug))
summary(mcmc(betaAug))
plotAugmented1 <- qplot(betaAug$V1, geom="histogram", fill=I("green"), col=I("black"), 
                        alpha= I(.75), bins=40, xlab="beta 1") 
plotAugmented2 <- qplot(betaAug$V2, geom="histogram", bins=40, fill=I("green"), col=I("black"),
                        alpha=I(.75), xlab="beta 2" ) 
grid.arrange(plotAugmented1, plotAugmented2, plotAC1, plotAC2, 
             nrow = 2, ncol=2, top=textGrob("Comparison of Albert & Chib Vs. Data Augmentation, \nData Augmentation Row 1"))

#Q2 Part 3====
effectiveSize(betaAug)
effectiveSize(betaAC)
#Q2 Part 4====
pgpdf <- function(y, t, nu, theta, pPqInv){
  if( y < t){
    p <- dinvGauss(y, nu, 1)
  }else{
    p <- dexp(y, theta)
  }
  p*pPqInv
}

piecewiseCoefs <- function(n, x, t){
  if( x < t ){
    pi * (n + .5) * (2/(pi*x))^(1.5) * exp(- (2*(n+.5)^2)/x )
  }else{
    pi * (n + .5) * exp(- (n+.5)^(2) *pi*pi *.5*x)
  }
}

riglower <- function(mu, lambda,t ){
  x <- t + 1
  while(x > t){
    y <- rnorm(1,0,1)^2
    x <- mu + .5*mu*mu*y - .5*mu*sqrt(4*mu*y + (mu*y)^2)
    u <- runif(1,0,1)
    if(u > mu/(mu+x)){
      x <- (mu^2)/x
    }else{
      x <- t + 1
    }
  }
}

rig <- function(mu, lambda, t){
  if(mu > t){
    z < 1/mu
    stopstop <- 0
    while(stopstop == 0){
      stop <- 0
      while(stop == 0){
        e <- rexp(1,1)
        eprime <- rexp(1,1)
        if(e*e < 2*eprime/t){
          stop <- 1
        }
      }
      x <- t/(1 + e)^2
      alpha <- exp(-.5*z*z*x)
      u <- runif(1,0,1)
      if(u < alpha){
        stopstop <- 1
      }      
    }
  }else{
    y <- rnorm(1,0,1)
    y <- y*y
    x <- mu + .5*mu*mu*y - .5*mu*sqrt(4*mu*y + (mu*y)^2)
    u <- runif(1,0,1)
  }
}

polyaGamma <- function(ndraws, z){
  keep <- numeric(ndraws)
  y <- abs(z)*.5
  t <- .64
  theta <- (.5*y*y) + (.125*pi*pi)
  p <- .5*(pi/theta) * exp(-theta*t)
  q <- 2 * exp(-abs(y))*pinvGauss(t, 1/y, 1)
  accept <- 1
  MaxIts <- 100
  while(accept <= ndraws){
    u <- runif(1,0,1)
    v <- runif(1,0,1)
    if(u < p/(p+q)){
      x <- t + (rexp(1)/theta)
    }else{
      mu <- 1/y
      if(mu > t){
        val <- -1
        while(runif(1,0,1) > val){
          chipropose <- rchisq(1,1)
          while(chipropose < t){
            chipropose <- rchisq(1,1)
          }
          x <- 1/chipropose
          val <- exp(-(y^2)*.5*x)
        }
      }else{
        x <- t + 1
        while(t < x){
          x <- rinvGauss(1, mu, 1)
        }
      }
    }
    n <- 0
    S <- piecewiseCoefs(0, x, t)
    Y <- v*S
    stopSampling <- 0
    its <- 1
    while(stopSampling == 0 && its < MaxIts){
      n <- n + 1
      its <- its + 1
      if( (n %% 2) == 0){
        S <- S + piecewiseCoefs(n, x, t)
        accepts <- ndraws + 1
        if(Y > S){
          stopSampling == 1
        }
      }else{
        S <- S - piecewiseCoefs(n, x, t)
        if(Y < S){
          keep[accept] <- x*.25
          accept <-accept + 1
          stopSampling <- 1
        }
      }
    }
  }
  keep
}

z <- polyaGamma(10000, 1)
zdf <- as.data.frame(z)
ggplot(data=zdf, aes(x=z)) + geom_density(bw=.05) 

naivePolyaGamma <- function(N, w, z, terms){
  sample <- numeric(N)
  zsquare <- z*z
  oneOver2PiSquared <- 1/(2*pi*pi)
  for(i in 1:N){
    S <- 0
    gams <- rgamma(terms, w,1)
    for(k in 1:terms){
      den1 <- (k - .5)^2
      den2 <- zsquare*.25*pi^(-2)
      S <- S +  (gams[k] / ( den1+den2 ))
    }
    sample[i] <- oneOver2PiSquared*S
  }
  sample
}

z <- naivePolyaGamma(10000, 1, 1, 100)
zdf <- as.data.frame(z)
ggplot(data=zdf, aes(x=z)) + geom_density(bw=.025) 


updatePGVar <- function(priorVarInv, omega, X){
  B <- solve(priorVarInv + (t(X)%*% diag(omega) %*% X))
  B
}
updatePGBeta <- function(X,z, updateVar, betaPrior, priorVarInv){
  b <- updateVar %*% ( priorVarInv %*% betaPrior + (t(X)%*%z) )
  b
}

gibbsPolyaGamma <- function(y, X, sims){
  rc <- dim(X)
  nobs <- rc[1]
  beta <- solve(t(X)%*%X) %*% t(X) %*% y
  omega <- numeric(nobs)
  betaPrior <- rep(0, rc[2])
  BPrior <- 10*diag(rc[2])
  priorVarInv <- solve(BPrior)
  kappa <- y -.5
  betaMatPG <- matrix(0, nrow=sims, ncol=rc[2])
  for(i in 1:sims){
    for(j in 1:nobs){
      z <- X[j,] %*% beta
      omega[j] <- polyaGamma(1, z)
    }
    B <- updatePGVar(priorVarInv, omega, X)
    b <- updatePGBeta(X, kappa, B, betaPrior, priorVarInv)
    beta <- t(rmvnorm(1, t(b), B))
    betaMatPG[i, ] <- t(beta)
  }
  betaMatPG
}

gibbsNaivePolyaGamma <- function(y, X, sims){
  rc <- dim(X)
  nobs <- rc[1]
  beta <- solve(t(X)%*%X) %*% t(X) %*% y
  omega <- numeric(nobs)
  betaPrior <- rep(0, rc[2])
  BPrior <- 10*diag(rc[2])
  priorVarInv <- solve(BPrior)
  kappa <- y -.5
  betaMatPG <- matrix(0, nrow=sims, ncol=rc[2])
  for(i in 1:sims){
    for(j in 1:nobs){
      z <- X[j,] %*% beta
      omega[j] <- naivePolyaGamma(1, 1, z, 100)
    }
    B <- updatePGVar(priorVarInv, omega, X)
    b <- updatePGBeta(X, kappa, B, betaPrior, priorVarInv)
    beta <- t(rmvnorm(1, t(b), B))
    betaMatPG[i, ] <- t(beta)
  }
  betaMatPG
}

betaMatPG <- as.data.frame(gibbsPolyaGamma(y,X,sims))
betaMatPG <- betaMatPG[floor(.1*sims):sims,]
plot(mcmc(betaMatPG))
summary(mcmc(betaMatPG))
betaMatNaive <- as.data.frame(gibbsNaivePolyaGamma(y, X, 500))
pgpsa <- ggplot(data=betaMatPG, aes(x=V1)) + 
  geom_histogram(col=I("black"), fill=I("purple"), alpha=I(.6)) +
  xlab("PSA")
pggs <- ggplot(data=betaMatPG, aes(x=V2)) + 
  geom_histogram(col=I("black"), fill=I("purple"), alpha=I(.6)) +
  xlab("GS")
grid.arrange(pgpsa, pggs, nrow=1)
#Q2 Part 5====
loglike <- function(y, x, beta){
  z <- x %*% beta
  A <- y*log(plogis(z))
  B <- (1-y)*log(1-A)
  f <- sum(A+B)
  f
}

CPO <- function(y, X, betaMatrix){
  cpo <- -apply(t(betaMatrix), MARGIN=2, loglike, y=y, x=X)
  cpo
}

lpml <- function(y,X,betaMatrix){
  cpo <- CPO(y,X,betaMatrix)
  logN <- log(length(cpo))
  maxval <- max(cpo)
  lpml <- logN - sum(exp(cpo - maxval)) - maxval
  lpml
}

race <- as.numeric(prostatedata$Race)
Xrace <- as.matrix(cbind(X,race))

bac <- gibbsAlbertChib(y,Xrace, 500)
bda <- gibbsDataAug(y,Xrace, 500)
bpg <- gibbsPolyaGamma(y,Xrace, 500)

lac <- lpml(y, X, betaAC)
lag <- lpml(y, X, betaAug)
lpg <- lpml(y, X, betaMatPG)
lacrace <- lpml(y, Xrace, bac)
lagrace <- lpml(y, Xrace, bda)
lpgrace <- lpml(y, Xrace, bpg)
exp(lac - lacrace)
exp(lag - lagrace)
exp(lpg - lpgrace)

colnames(Xrace) <- c("PSA", "GS", "Race")
summary(lm(y~Xrace))
