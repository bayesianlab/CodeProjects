# prob of chocie tests
source('~/R projects/choice_example.R')
x <- probabilityOfChoice(1, testX[,1], testBetas)
y <- probabilityOfChoice(1, testX[,2], testBetas)
y
x <- logLikelihoodMultLogit(1, testX, testBetas)
x