source('~/R projects/swiss_bayes_example.R')
data(swiss)
DATA <- matrix(unlist(swiss), nrow = 47)
y <- DATA[1:47, 1]
x <- DATA[1:47, 2:6]
row_col <- dim(x)
const <- rep(1,row_col[1])
x <- cbind(const, x)
post <- linRegGibbSampler(y,x, 10000,1000)

