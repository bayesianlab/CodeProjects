library(vars)
library(mFilter)
library(ggplot2)
library(tseries)
library(readr)
cpi <- read_csv("CodeProjects/R/time series/CPILFESL.csv")
gs1 <- read_csv("CodeProjects/R/time series/GS1.csv")
indpro <- read_csv("CodeProjects/R/time series/INDPRO.csv")
cpi <- cpi[637:786, ]
gs1 <- gs1[682:831, ]
indpro <- indpro[1093:1242,]


plot(cpi, type = "l")
plot(gs1, type = "l")
plot(indpro, type = "l")
cpi <- ts(
  cpi$CPILFESL,
  start = c(2010, 1),
  end = c(2022, 6),
  frequency = 12
)
gs1 <- ts(
  gs1$GS1,
  start = c(2010, 1),
  end = c(2022, 6),
  frequency = 12
)
indpro <-
  ts(
    indpro$INDPRO,
    start = c(2010, 1),
    end = c(2022, 6),
    frequency = 12
  )
lindpro <- log(indpro)
lfdcpi <- log(cpi[2:150]) - log(cpi[1:149])

gs1 <- gs1[2:150]
lindpro <- lindpro[2:150]
adf.test(lfdcpi)
pp.test(lfdcpi)

adf.test(gs1)
adf.test(lindpro)
Vec <- cbind(lcpi, lindpro, gs1)
v1 <- VAR(Vec, p = 2, type = "const")
Phi <-
  rbind(
    v1$varresult$lcpi$coefficients,
    v1$varresult$lindpro$coefficients,
    v1$varresult$gs1$coefficients
  )
summary(v1)


M <- c(Vec[149,], Vec[148,], 1)
Phi %*% M

varforeUtil <- function(coefMat, dataVect, f, lags, periods, i) {
  if (i == periods)
  {
    f[, i] <- coefMat %*% dataVect
    f
  }
  else{
    print(dataVect)
    f[, i] <- coefMat %*% dataVect
    eqns <- nrow(coefMat)
    temp <- dataVect[1:(eqns * (lags - 1))]
    dataVect[1:eqns] <- f[, i]
    dataVect[(eqns + 1):(length(dataVect) - 1)] <- temp
    print (dataVect)
    varforeUtil(coefMat, dataVect, f, lags, periods, i + 1)
  }
}

varfore <- function (coefMat, dataVect, lags, periods) {
  Fmat <- matrix(0, nrow(coefMat), ncol = periods)
  Fmat <- varforeUtil(coefMat, dataVect, Fmat, lags, periods, 1)
  Fmat
}

# varforeErrors <- function(residualMat, coefMatNoConstant, lags, periods){
#   Sigma <- t(R)%*%R
#   I <- diag(rep(1,lags))
#   KSigma <- kronecker(I, Sigma)
#   coefMatNoConstant%*%KSigma%*%(t(coefMatNoConstant))
#
#
# }
Fmat <- varfore(Phi, M, 2, 2)
Fmat
predict(v1, n.ahead = 2)

impulse <- function(coefmat, periodsOut, epsVect, lags) {
  response <- matrix(0, length(epsVect), periodsOut + lags)
  response[, lags] <-  epsVect
  for (p in (lags + 1):(periodsOut + lags)) {
    response[, p] <-
      coefmat %*% as.vector(response[, (p - 1):(p - lags)])
  }
  response
}


ortho_impulse <- function(coefmat, B0inv, shock, eqns, lags, periodsOut){
  Iden <- diag(rep(1, eqns*(lags-1)))
  Zeros <- matrix(0, eqns*(lags-1), eqns)
  Phi <- rbind(coefmat, cbind(Iden, Zeros))
  Ik <- cbind(diag(rep(1, eqns)), matrix(0, eqns, (lags-1)*eqns))
  M <- B0inv
  Yt <- matrix(0, eqns*lags, 1)
  res <- matrix(0, eqns, periodsOut)
  res[,1] <- shock
  Ai <- Phi
  for(i in 2:periodsOut){
    Ai <- Ai%*%Phi
    res[,i] <- (Ik%*%Ai%*%t(Ik))%*%B0inv%*%res[,i-1]
  }
res
}
constants <- Phi[, 7]
coefmat <- matrix(Phi[, 1:6], nrow = 3)

R <-
  cbind(
    v1$varresult$lcpi$residuals,
    v1$varresult$lindpro$residuals,
    v1$varresult$gs1$residuals
  )
Sigmahat <- t(R)%*%R
B0inv <- t(chol(Sigmahat))
diag(B0inv)
shock <- c(1,0, 0)
res <- ortho_impulse(coefmat,B0inv, shock, 3,2,100)
res
res2 <- impulse(coefmat, 100, shock, 2)
plot(res[1,], type="l")
plot(res2[1,], type="l")
plot(irf(v1))








summary(v1)$varresult$lcpi$sigma
epsVect <- c(.001, 0, 0)
lags <- 2
ir <- impulse(recur_coef, 50, epsVect, lags)
plot(ir[1, ], type = "l")
plot(ir[2, ], type = "l")
plot(ir[3, ], type = "l")






###
lfdindpro <- lindpro - log(indpro[1:149])
lfdindpro100 <- 100 * lfdindpro
lfdcpi100 <- lfdcpi * 100
adf.test(lfdindpro)
Vec2 <- cbind(lfdcpi, lfdindpro, gs1)

v2 <- VAR(Vec2, 2)
summary(v2)

ts.plot(Vec2)
