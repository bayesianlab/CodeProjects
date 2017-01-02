# hw1part C
baseball <- readRDS( '/Users/dillonflannery-valadez/Coding/R/Stat210/baseball.rds')
  # 1
plot(baseball$payroll, baseball$wins, ylim=c(30, 150), xlim=c(30, 200), 
     xlab='Payroll', ylab='Wins')
  # 2
    # Sum of xi
sumXi <- sum(baseball$payroll)
sumSqdXi <- sum(baseball$payroll^2)
avgPay <- mean(baseball$payroll)
sumSqdDevXi <- sum((baseball$payroll - avgPay)^2)
sumXiYi <-baseball$payroll %*% baseball$wins
sumYi <- sum(baseball$wins)
sumSqdYi <- sum(baseball$wins^2)
avgWins <- mean(baseball$wins)
sumSqdDevYi <- sum( (baseball$wins-avgWins)^2 )
covXiYi <- sum( (baseball$payroll - avgPay)*(baseball$wins- avgWins) )
cat(sprintf(paste(' sumXi = %.3f\n sumSqdXi = %.3f\n avgPay = %.3f\n sumSqdDevXi = %.3f\n', 
            'sumXiYi = %.3f\n sumYi = %.3f\n sumSqdYi = %.3f\n avgWins = %.3f\n',
            'sumSqdDevYi = %.3f\n covXiYi = %.3f\n'), sumXi, sumSqdXi, avgPay, sumSqdDevXi, 
            sumXiYi, sumYi, sumSqdYi, avgWins, sumSqdDevYi, covXiYi))  

  # 3 Find the LS Regression line using the summaries
lsLine <- function(yi,xi, level=0.05i, dispYn=1){
  n <- length(yi)
  alpha2 <- level/2
  tval <- qt(1-alpha2, n-2)
  df <- n - 2
  xbar <- mean(xi)
  xbarSqd <- xbar^2
  sxx <- sum( (xi - xbar)^2 )
  wi <- (xi - xbar) / sxx
  b1 <- wi %*% yi
  b0 <- mean(yi) - b1*xbar
  yhat <- b0 + b1*xi
  residuals <- yi - yhat
  rss <- residuals %*% residuals
  sigmaSqdHat <- rss * (1/df)
  stdevb1 <- sqrt(sigmaSqdHat / sxx)
  stdevb0 <- sqrt(sigmaSqdHat*(1/n + xbarSqd/sxx))
  tStatb1 <- b1 / stdevb1
  tStatb0 <- b0 / stdevb0
  tStats <- c(tStatb0,tStatb1)
  margin <- stdevb1 * tval
  slopeCi <- c(b1 - margin, b1 + margin)
  if (dispYn == 1) {
    cat('Regression Results:\n')
    cat('\t  \t  Estimate   t-statistic (Two-sided)\n')
    cat(sprintf('\tIntercept  %.4f    %.4f\n', b0, tStats[1]))
    cat(sprintf('\tSlope      %.4f     %.4f\n', b1, tStats[2]))
    cat(sprintf('\tCritical t-value %.4f with %i degrees of freedom. Level=%.3f\n', 
              tval, n-2, alpha2))
    cat(sprintf('\tSlope confidence interval: [%.4f, %.4f]\n\n', slopeCi[1], slopeCi[2]))
  }    
  list(c(b0,b1), yhat, residuals, tStats, slopeCi, rss, sxx, xbar, sigmaSqdHat, tval, 
       n, level)
}

get_prediction <- function(regline, predict, dispYn=1){
  sigmaSqdHat <- regline[[9]]
  n <- regline[[11]]
  alpha2 <- regline[[12]] / 2
  tval <- regline[[10]]
  fval <- qf(1-alpha2, 2, n-2)
  xbar <- regline[[8]]
  sxx <- regline[[7]]
  n <- regline[[11]]
  sefit <- sqrt(sigmaSqdHat*( 1/n + ((predict - xbar)^2 / sxx) ) ) 
  sepred <- sqrt(sigmaSqdHat) + sefit
  b0 <- regline[[1]][1]
  b1 <- regline[[1]][2]
  ypred <- b0 + b1 * predict
  predCi <- c(ypred - sepred*tval, ypred + sepred*tval)
  expectationCi <- c(ypred - sefit * sqrt(2 * fval), ypred + sefit * sqrt(2 * fval))
  if(dispYn == 1){
  cat(sprintf('Predicted response given %.2f\n', predict))
  cat(paste('\ty value =', round(ypred, 4), '\n'))
  cat(paste('\tConfidence Interval for prediction = [', round(predCi[1], 4), ',',
                     round(predCi[2], 4), ']\n' )) 
  cat(sprintf('\tE[Y|X = x] confidence interval = [%.4f, %.4f]', expectationCi[1], 
              expectationCi[2]))
  }
  list(ypred, predCi, expectationCi)
}

lsl <- lsLine(baseball$wins, baseball$payroll, .05, 1)

xspace <- 1:max(baseball$payroll)
expecLine <- matrix(nrow=length(xspace), ncol=2)
predLine <- matrix(nrow=length(xspace), ncol = 2)
yfit <- numeric(length(xspace))
for(i in 1:length(xspace)){
  predout <- get_prediction(lsl, xspace[i], 0)
  expecLine[i, 1] <- predout[[3]][2]  
  expecLine[i, 2] <- predout[[3]][1]
  predLine[i, 1] <- predout[[2]][1]
  predLine[i, 2] <- predout[[2]][2]
  yfit[i] <- predout[[1]]
}

lines(expecLine[,1], col="red", lty=2)                                    
lines(expecLine[,2], col="red", lty=2)
lines(predLine[,1], col="blue", lty=2)
lines(predLine[,2], col='blue', lty=2)
lines(yfit, col="118")
legend(30, 150, c("Fitted Value CI", "Prediction interval", "y-fitted"), 
       col=c('red', 'blue', "118"), lty=c(2, 2, 1), cex=0.5)


pred100 <- get_prediction(lsl, 100, 1)
pred200 <- get_prediction(lsl, 200, 1)
pred200[[1]] - pred100[[1]]
slope <- lsl[[1]][2]
slope * (100)
t <- lsl[[10]]
se <- 100*lsl[[9]] /lsl[[7]] 
ci <- c(slope*100 - se*t, slope*100 + se*t)
ci
