#Section1====
parti <- function(theta, k){
  res <- theta^(-k) * dgamma(theta, 196.5, rate =280)
}

partb <- function(theta, k){
  res <- theta^(-k) * dbeta(theta, 196.5, 1120)
}


num <-integrate(parti, 0, Inf, k=1)
den <- integrate(parti,0,Inf,k=2)
cat(num[[1]]/den[[1]])

num <- integrate(partb, 0, Inf, k=1)
den <- integrate(partb, 0, Inf, k=2)
cat(num[[1]]/den[[1]])

# Section 2====
Y <- rnorm(10000,0,5)
eY <- exp(Y)
X <- eY/(1+eY)
plot(density(X))
plot(hist(X))
weightedBeta <- function(X,cuts){
  Fn <- ecdf(X)
  sto <- Fn(1/cuts)*dbeta(X,1,cuts)
  for(j in 2:cuts){
    jm1 <- j-1
    b <- j/cuts
    a <- jm1/cuts
    beta <- cuts - j + 1
    sto <- sto + ((Fn(b) - Fn(a))*dbeta(X,j,beta))
  }
  sto
}
Z <- weightedBeta(X, 20)
plot(density(Z), main="Density Z")
hist(Z)

# Section 3====
library(data.table)
library(rjags)
X <-fread('http://www.ics.uci.edu/~mguindan/teaching/stats225/zscores.txt')
p6data <-  list(y = X$V1, N = length(X$V1))
mod <- jags.model("~/Google Drive/CodeProjects/R/p6.bug", data = p6data, n.chains=3, n.adapt = 1000)
res <- coda.samples(mod, var = c("y", "mu", "gamma"), n.iter=3000)
R <- data.frame(as.matrix(res))
sto <- numeric(200)
D <- dim(R)
for(i in 1:200){
  sto[i] <- sum(R[,i])/D[1]
}

sort(1 - sto)
plot(sto, col="blue")
fdr <- function(k, pi, level){
  lpi <- length(pi)
  indicator <- (pi < k)
  betag <- sum( (1-pi) %*% indicator )
  den <- sum(indicator)
  res <- (betag / den) - level
  res
}

optimize(fdr, interval=c(min(sto),max(sto)), tol=.0001, pi=sto, level=.05)

# Section 4====
dgalenshore <- function(x,a,theta){
  d <- (2/gamma(a)) * theta^(2*a) * x^( (2*a) - 1) * exp(- (theta*x)^2 )
}
Fg <- function(x){
  K <- 68.34375
  res <- K * x * (( (x^2) + 2.25)^(-4))
}
1 - integrate(Fg, 0,1)[[1]]
K <- 68.34375
1- (1 - (K/6) * (3.25)^(-3))
