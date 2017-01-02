setwd('/Users/dillonflannery-valadez/Coding/R/Stat210/')
out <-  matrix(ncol = 4, scan('dataHW1.txt'), byrow = F)
par(mfrow=c(1,1))
plot(out[,3], out[,4], pch=19)
g1 <- c(out[,2] == 0)
group1 <- out[out[,2] == 0,]
group2 <- out[out[,2] != 0, ]
par(mfrow = c(1,2))
plot(group1[,3], group1[,4], pch=19, col='blue', xlab='x', ylab='y',
     main='Group 1')
plot(group2[,3], group2[,4], pch=19, col='red', xlab='x', ylab='y', 
     main = "Group 2")

