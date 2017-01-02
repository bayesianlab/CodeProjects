# Part A
# Part 1)
x <- c(5,6,3,8,7,6,4,4,7,6)
boxplot(x, col='grey50', border='blue', xlab=c('x'), main= 'Part a')
# Part 2)
summary(x)
xSampleAvg <- summary(x)[[4]]
# Part 3)
xSampleStDev <- sd(x)
xSampleStDev
upb <- mean(x) + qnorm(0.05, 0,1)*sd(x)
lowb <- mean(x) - qnorm(0.05, 0,1)*sd(x)
# Part 4)
  # Part a) H0 = 5 vs Ha != 5, a = .05, two sided
  # Part b)
testStatistic <- (mean(x) - 5) / xSampleStDev
  # Part c) Distribution of test statistic is t under H0, n < 30
  # Part d) Reject when test statistic is less than Prob(testStat < t), Prob(testStat > t)
  # or when p-value (2*Prob(T > testStat) < 0.05)

pValue <- 2*(1-pt(testStatistic, 9))
pValue
# Can't reject H0, the pop. mean is probably not different form 5 based on this test

