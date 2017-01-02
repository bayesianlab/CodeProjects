
data(swiss)

library(MCMCpack)
library(pscl)
post <- MCMCregress(Fertility ~
                      + Agriculture + Examination +
                      + Education + Catholic
                      + Infant.Mortality,
                    data=swiss)
summary(post)
g <- lm(Fertility ~                      
          + Agriculture + Examination +
          + Education + Catholic
        + Infant.Mortality,
        data=swiss)
summary(g)
DATA <- matrix(unlist(swiss), nrow = 47)
x <- DATA[1:47, 2:6]
const <- rep(1,row_col[1])
x <- cbind(const, x)
row_col <- dim(x)
y <- DATA[1:47, 1]

x_prime_x <- t(x) %*% x
B0 <- diag(row_col[2])
beta0 <- rep(0, row_col[2])
alpha0 <- 6
delta0 <- .4
n <- row_col[1]
alpha1 <- (alpha0 + n)/2


sims <- 10000
beta <- matrix(nrow = sims, ncol = row_col[2])
sigma2 <- numeric(sims)
sigma2[1] <- 1


for(s in 2:sims){
  
  v <- (1/sigma2[s-1])
  Beta1Next <-  solve(  ( v * x_prime_x) + B0 )
  betaBarNext <-  Beta1Next %*% ( ((v * t(x)) %*% y) + (B0 %*% beta0) )
  beta[s, 1:row_col[2]] <- mvrnorm(n=1, mu=betaBarNext, Sigma=Beta1Next)
  residual <- y - (x %*% beta[s, 1:row_col[2]])
  # Need to flip beta
  deltaNext <- (1/2)*(delta0 + t(residual) %*% residual)^-1
  sigma2[s] <- rinvgamma(1, alpha1, deltaNext) 
  
}
burn_in <- 1000
beta <- beta[burn_in:sims, 1:row_col[2]]
sigma2 <- sigma2[burn_in:sims]
for(i in 1:6){
  print(mean(beta[,i]))
}


