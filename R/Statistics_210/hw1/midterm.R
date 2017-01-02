# Midterm
options(verbose = FALSE)
library(ggplot2)
library(reshape2)
library(car)
library(corrgram)
midtermData <- matrix(scan("~/Coding/R/Stat210/datamt"), ncol=4, byrow=T);
head(midtermData)
n1 <- 1:50
n2 <- 51:100
dMem <- midtermData[,4] - midtermData[,3]
amyg <- midtermData[,2]
justData <- cbind(dMem, amyg)
noGroups <- cbind(rep(1,100), amyg)
y <- dMem
xtop <- matrix(c(rep(1,50), rep(0,50)), nrow = 50, ncol= 2)
xbottom <- matrix(c(rep(0,50), rep(1,50)), nrow = 50, ncol= 2)
x1 <- rbind(xtop, xbottom)

xtop <- cbind( rep(1,50), amyg[n1], rep(0,50), rep(0,50))
xbottom <- cbind(rep(0,50), rep(0,50), rep(1,50), amyg[n2])
x2 <- rbind(xtop, xbottom)

ols <- function(y,x, df){
  xpxInv <- solve(t(x)%*%x)
  betaOLS <-  xpxInv %*% t(x) %*% y
  fit <- x %*% betaOLS
  res <- y - fit
  print(dim(res))
  res2 <- t(res) %*% res
  rowcol <- dim(x)
  sigmahat2 <- res2 / df
  seBeta <- sqrt(diag(xpxInv) * sigmahat2[1])
  cat(sprintf('Coefs\n'))
  print(betaOLS)
  cat(sprintf('Std err\n'))
  print(seBeta)
  cat(sprintf('t statistics\n'))
  print(betaOLS/seBeta)
  list(betaOLS, seBeta, res)
}

olsPredict <- function(y,x, df, c){
  xpxInv <- solve(t(x)%*%x)
  betaOLS <-  xpxInv %*% t(x) %*% y
  fit <- x %*% betaOLS
  res <- y - fit
  res2 <- t(res) %*% res
  rowcol <- dim(x)
  sigmahat2 <- res2 / df
  seBeta <- sqrt(diag(xpxInv) * sigmahat2[1])
  
  pred <- c %*% betaOLS
  vPred <- (c %*% xpxInv %*% c + 1) * sigmahat2
  c(pred - qt(.975, df) * sqrt(vPred),
  pred + qt(.975, df) * sqrt(vPred))
}

newAmygdala <- seq(.5, 12, by=.25)
lamy <- length(newAmygdala)
dfr <- dataMat2[1:lamy, 1:6]
dfr$amygdala2 <- newAmygdala
dfr <-dfr[,3:6]
dfr
predIntervals <- as.data.frame(predict(lmResults2, dfr, interval='predict'))
predIntervals <- cbind(predIntervals, newAmygdala)
ggplot(data=predIntervals) + geom_line(aes(x=newAmygdala, y=fit)) +
  geom_line(linetype=2, aes(x=newAmygdala, y=lwr), color = 'red') + 
  geom_line(aes(x=newAmygdala, y=upr), linetype=2,  color ='red') +
  labs(x='Amygdala', title='Prediction Intervals (in red) and Predictions (in black)',
       y = 'Estimated Value')

# For comparing just the intense treatment effects
dataMat1 <- as.data.frame(cbind(1:100, y, x1))
colnames(dataMat1) <- c('ID', 'y', 'c1', 'c2')
# c1 1 -> Basic, c2 -> 1 Advanced
dataMat1$c1 <- factor(dataMat1$c1)
dataMat1$c2 <- factor(dataMat1$c2)
levels(dataMat1$c1) <- c('AT', 'BT')
levels(dataMat1$c2) <- c('BT', 'AT')
# Means of groups
summary(dataMat1)
aggregate(dataMat1$y~dataMat1$c1, FUN=mean)
aggregate(dataMat1$y~dataMat1$c1, FUN=sd)

# Data with amygdala scores
dataMat2 <- as.data.frame(cbind(1:100, y,x2))
colnames(dataMat2) <- c('ID', 'y', 'c1', 'amygdala1', 'c2', 'amygdala2')
dataMat2$c1 <- factor(dataMat2$c1)
dataMat2$c2 <- factor(dataMat2$c2)
levels(dataMat2$c1) <- c('AT', 'BT')
levels(dataMat2$c2) <- c('BT', 'AT')

# Group 1
ggplot(dataMat1, aes(c1, y))  + geom_jitter(aes(colour=c2)) +
  labs(y = 'Difference = U_1i - U_0i', x = 'Therapy Intensisty', 
       title = 'Dependent variable Scatter Plot', colour = 'Therapy') + 
  scale_color_manual(values = c('blue', 'red'), labels = c('Basic', 'Advanced')) 

# Comparing amygdala activation
d1 <- dataMat2[1:50,]
d2 <- dataMat2[51:100,]

cor(justData[51:100,] )
cor(justData[1:50,])
# Group 1
ggplot(d1) + geom_point(aes(x=amygdala1, y = y)) + 
  labs(y = 'Difference = U_1i - U_0i', x = 'Amygdala', 
       title = 'Basic Treatment and Amygdala Activation')
# Group 2
ggplot(d2) + geom_point(aes(x=amygdala2, y=y)) + 
  labs(y = 'Difference = U_1i - U_0i', x = 'Amygdala', 
       title = 'Advanced Treatment and Amygdala Activation')

# Model results 
lmResults <- lm(y~x2)
lmResults2 <- lm(data=dataMat2, y ~ c1 + amygdala1 + c2 + amygdala2 - 1)
summary(lmResults2)
lmNoGroups <- lm(y~noGroups -1)
summary(lmResults)
summary(lmNoGroups)
model2Residuals <- y - lmResults$fitted.values
model2fits <- lmResults$fitted.values
dataMat2 <- cbind(dataMat2, model2fits, model2Residuals)
modelCoefs <- lmResults$coefficients
check1 <- sum((y - x2 %*% modelCoefs)^2)
check2 <- sum((y - noGroups %*% lmNoGroups$coefficients)^2)
c <- as.numeric(c(1,1,-1,-1))
cBeta <- c %*% modelCoefs
ssr <- sum(lmResults$residuals ^ 2)
sigmaHatSqd <- ssr / (length(y) - 4)

ssrRestricted <- sum(lmNoGroups$residuals^2)
F <- ((ssrRestricted - ssr) / 2) / (ssr / (length(y) - 4))
F
fcrit <- qf(.95, 2, 96)
fcrit
fPvalue <- 1-pf(F, 2, 96) 
anova(lmResults, lmNoGroups)

ls <- ols(y, x2, 96)
upLim <- ls[[1]] + qt(.975, 96) * ls[[2]]
lowLim <- ls[[1]] - qt(.975, 96) * ls[[2]]
cbind(lowLim, upLim)
confint(lmResults)

# Predicted actual scatter
ggplot(dataMat2) + geom_point(aes(x = ID, y = model2fits), color= 'red') + 
  geom_point(aes(x=ID, y=y)) +
  labs(x='Observation', y = 'Predicted (red) vs. Actual (black)')

# Hist of actual
ggplot(dataMat2) + geom_histogram(aes(y, fill=c2), col='black', bins=15) + 
  labs(x = 'Actual Values')

# hist of fitted
ggplot(dataMat2) + geom_histogram(aes(model2fits, fill=c2), col='black',bins=15) + 
  labs(x ='Fitted values')

# scatter of residuals
ggplot(dataMat2) + geom_point(aes(x=model2fits, y=model2Residuals)) +
  labs(y = 'Residual', x = 'Fitted Values', 
       title = 'Residuals vs Fitted Values')

# histogram of residuals
ggplot(dataMat2) + geom_histogram(aes(model2Residuals), fill='blue', col='black', bins= 10) +
  labs(x='Residuals')



summary(dataMat2)
