C <- matrix(c(1, 200), nrow=1)
C

linm <- lm(data=Forbes, bp~lpres)
summary(linm)
cf <- linm$coefficients

nd <- data.frame(lpres = 200)
predict(linm, nd, interval="prediction")
shatsqd <- sum(linm$residuals^2)/(length(linm$residuals) -2)
shatsqd
x <- as.matrix(cbind(rep(1,17), Forbes$lpres))
xpx <- solve(t(x)%*%x)
xpx
sep <- sqrt(shatsqd * ( 1 + (C  %*%xpx%*% t(C))))
t <-qt(.975, 15)
est <- sum(cf * C)
upr <- est + sep*t
lwr <- est -t*sep
sxx <- sum((Forbes$lpres - mean(Forbes$lpres))^2)
n <- nrow(Forbes)
est + t*sqrt(shatsqd*(1+(1/n) + ((200-mean(Forbes$lpres))^2)/sxx))
upr
lwr
