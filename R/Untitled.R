library(mvtnorm)
n <- 100
X <- rmvnorm(n, c(0,0,0), diag(3))
X <- cbind(1, X)

y <- X%*% beta + rnorm(n,0,1)

Sigma <- matrix(c(1,.3,.4, .3,1,.2, .4,.2,1), ncol=3)
Sigma
mu <- c(.2,.3,.3)
dmvt(c(1,.2,-3), mu,Sigma,log=TRUE  )
