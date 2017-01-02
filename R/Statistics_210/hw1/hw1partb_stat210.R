# Part B
library(ggplot2)
library(reshape2)
  # 1 side by side boxplots
males <- c(5,5,6,4,6,7,3,4,5,5)
females <- c(4,5,4,3,3,5,4,4,2,6)
mfData <- data.frame(cbind(males, females))
mfData <- melt(mfData)
ggplot(mfData, aes(variable, value)) + geom_boxplot()
  # 2 95% CI
varMale <- var(males)
varFemale <- var(females)
nM <- length(males)
nF <- length(females)
sp <- sqrt(((nM - 1)*varMale + (nF - 1)*varFemale) / (nM + nF - 2))
rootNobs <- sqrt((1/nM) + (1/nF))
den <- sp * rootNobs
meanMales <- mean(males)
meanFemales <- mean(females)
diffMeans <- meanMales - meanFemales
degFreedom <- (nM + nF) - 2
tVal <- -1*qt(.025, degFreedom)
lowb <- diffMeans - tVal *den
upb <- diffMeans + tVal * den
interval <- c(lowb, upb)
interval
  # 3 H0 = difference is 0 vs Ha = it is not 0
  # b test statistic
testStat <- diffMeans / den
testStat
  # c Distribution is t under null
  # d Rejection and acceptance regions: when testStat < t= -2.1009, t > 2.1009
pVal <- 2*(1-pt(testStat, degFreedom))
  # e Fail to reject when pVal > 0.05
t.test(males,females, var.equal=TRUE, paired=FALSE)

males <- c(5,5,6,4,6,7,3,4,5,5)
females <- c(4,5,4,3,3,5,4,4,2,6)
x <- matrix(data=c(rep(0,10), rep(1,10)), nrow=20,ncol=2)
x[1:20,1] <- rep(1, 20)
y <- c(males,females)
estimate <- solve(t(x)%*%x) %*% (t(x) %*%y)
estimate
