#midterm2
library(leaps) 
library(MASS)
library(permute)
library(corrplot)
wine <- read.csv("/Users/dillonflannery-valadez/Coding/R/Stat210/winequality-red.csv",
      sep=";")

corMat <-  cor(wine[, 2:12])
corrplot(corMat, method="number")
