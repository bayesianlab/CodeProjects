library(mvtnorm)
n <- 100
X <- rmvnorm(n, c(0,0,0), diag(3))
X <- cbind(1, X)

y <- X%*% beta + rnorm(n,0,1)