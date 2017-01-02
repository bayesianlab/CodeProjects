#midterm2
library(MASS)
library(permute)
library(corrplot)
library(leaps) 
library(ggplot2)
library(sets)
library(e1071)
source('~/Coding/R/Stat210/midterm2/midtermFunctions.R')
wq <- read.csv("/Users/dillonflannery-valadez/Coding/R/Stat210/midterm2/winequality-red.csv",
         sep=";")
wine <- wq

corMat <-  cor(wine[, 1:11])
corrplot(corMat, method="number")

corrplot(cor(wine[,c(1:3,12)]), method ='number')
a <- lm(data=wine, quality~fixed.acidity)
b <- lm(data=wine, quality~volatile.acidity)
c <- lm(data=wine, quality~citric.acid)
summary(a)
summary(b)
summary(c)
# Seems like volatile.acidity is the one to use

corrplot(cor(wine[,c("free.sulfur.dioxide", "total.sulfur.dioxide", "sulphates", "quality")]),
         method="number")
qplot(wine$density, wine$quality)  + xlab("Density") + ylab("Quality")
summary(wine$density)
wine$density <- cut(wine$density, breaks=c(.9,.9968, 1.005), labels=c(0, 1))

setOf8 <- wine[, c(2, 8, 4:6, 9:11)]
dep <- wine[,12]

aicBic <- computeAkaikeBayesianInfo(dependent=dep, covariates=setOf8)

which.min(aicBic$AIC)
which.min(aicBic$BIC)
which.min(aicBic$`R-AIC`)
which.min(aicBic$`R-BIC`)

x <- forwardSelection(dep, setOf8)

y <- backwardSelection(dep, setOf8)

z <- forwardBackwardSelection(dep, setOf8)

df <- as.data.frame(cbind(dep,setOf8))

# R's forward and backward selection setup 
null <- lm(data=df, dep~1)
full <- lm(data=df, dep~.)
a <- step(null, scope=list(lower=null, upper=full), data=df, direction = "backward")
b <- step(full, data=df, direction = "backward")
c <- step(null, data=df, scope=list(lower=null, upper=full), direction = "both")
summary(a)
summary(b)
summary(c)
f <- formula(y~volatile.acidity + density + residual.sugar + chlorides + 
          free.sulfur.dioxide + pH + sulphates + alcohol)
plot(regsubsets(f, data= df, method="backward"))

# Best model with BIC is y = volatile.acidity+ chlorides+ pH+ sulphates+ alcohol
bestOf8 <- setOf8[, c(1, 4,6,7,8)]
interactions1 <- bestOf8$volatile.acidity * bestOf8[,2:5]
colnames(interactions1) <- c("va.chlor", "va.fsd", "va.pH", "va.alc")
interactions2 <- bestOf8$chlorides * bestOf8[,3:5]
colnames(interactions2) <- c("chlor.fsd", "chlor.pH", "chlor.alc")
interactions3 <- bestOf8$free.sulfur.dioxide * bestOf8[,4:5]
colnames(interactions3) <- c("fsd.pH", "fsd.alc")
interactions4 <- as.data.frame(bestOf8$pH * bestOf8[,5])
colnames(interactions4) <- "pH.alc"

df2 <- as.data.frame(cbind(bestOf8, interactions1, interactions2,interactions3,
                          interactions4))
tdf <- as.data.frame(cbind(dep, df2))
full <- lm(data=tdf, dep~.)
a<-step(null, scope= list(lower=null, upper=full), data=tdf, direction="forward")
summary(a)
x <- forwardBackwardSelection(dep, df2)
y<- forwardSelection(dep, df2)
j <- backwardSelection(dep, df2)[[1]]
# z <- computeAkaikeBayesianInfo(dep, df2)
# which.min(z$AIC)
# which.min(z$BIC)
# which.min(z$`R-AIC`)
# which.min(z$`R-BIC`)

sizedf2 <- dim(df2)
base <- bestOf8
baseLm <- lm(data=base, dep~.)
fstats<-0
for(i in 6:sizedf2[2]){
  newData <- as.data.frame(cbind(base, df2[,i]))
  colnames(newData)[6] <- colnames(df2)[i]
  print(colnames(newData))
  newLm <- lm(data=newData, dep~.)
  fstats[i-5] <- computeF(newLm, baseLm)
  print(computeF(newLm, baseLm))
}
print(fstats)

finalMod <- as.data.frame(cbind(base, df2$chlor.pH))
colnames(finalMod)[6] <- colnames(df2)[11]
head(finalMod)
summary(lm(data=finalMod, dep~.))

sizeFM <- dim(finalMod)
trainingPercent <- floor(.9*sizeFM[1])
set.seed(7)
testSetIndices <- sample(seq_len(sizeFM[1]), size=trainingPercent)
finalModTest <- finalMod[testSetIndices, ]
depTest <- dep[testSetIndices]
finalModValidate <- finalMod[-testSetIndices, ]
depValidate <- dep[-testSetIndices]
trainCoefs <- as.numeric(lm(data=finalModTest, depTest~.)$coefficients)
trainCoefs
constant <- rep(1, nrow(finalModValidate))
finalModValidate <- as.matrix(cbind(constant, finalModValidate), ncol = 7)                 
yValid <-  finalModValidate %*% trainCoefs
mean((depValidate - yValid)^2)
mean(bestOf8$chlorides)
