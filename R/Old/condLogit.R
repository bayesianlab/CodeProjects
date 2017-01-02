library(readstata13)
library(optimbase)

source('~/choiceDataFunctions.R', echo=FALSE)
source('~/clogitMax.R', echo=FALSE)

cldata <- read.csv("~/Rprojects/Rseminar/TableF18-2.txt", sep="")
X <- cldata
X <- X[,-c(3,4,7)]
Y <- cldata[, -c(3,4,6,7)]
Y <- createDummies(Y, 4, 1)
X <- createConLogitData(X, 4, 4, 4)

clogitModel(X, 4)
