setwd('/Users/dillonflannery-valadez/Coding/R/Stat210/')
out <-  matrix(ncol = 4, scan('dataHW1.txt'), byrow = F)
par(mfrow=c(1,1))
plot(out[,3], out[,4], pch=19, xlab='x', ylab='y')
g1 <- c(out[,2] == 0)
group1 <- out[out[,2] == 0,]
group2 <- out[out[,2] != 0, ]
par(mfrow = c(1,2))
plot(group1[,3], group1[,4], pch=19, col='blue', xlab='x', ylab='y',
     main='Group 1')
plot(group2[,3], group2[,4], pch=19, col='red', xlab='x', ylab='y', 
     main = "Group 2")
# ls estimator
# stack matrix 
y <- c(group1[,4], group2[,4])
x_1 <- group1[,3]
x_2 <- group2[,3]
X <- rbind(cbind(rep(1, length(x_1)), x_1, matrix(0, nrow=length(x_1), ncol=2)),
      cbind(matrix(0, nrow=length(x_2), ncol=2), rep(1, length(x_2)), x_2)  )
ls_estimate <- solve(t(X) %*% X) %*% (t(X) %*% y)
ls_estimate

b1 <- ls_estimate[2]
b2 <- ls_estimate[4]
sxx <- sum((X - mean(X))^2)
yfit <- X %*% ls_estimate
res <- y - yfit
sigmasqdhat <- t(res) %*% res / (nrow(X) - 4)
seb <- sqrt(sigmasqdhat / sxx )
testDiff <- (b1-b2) / sqrt(2*seb^2)
cat(testDiff)
if(abs(testDiff) > abs(qt(.025, nrow(X) - 4))){
  cat('significant')
}
