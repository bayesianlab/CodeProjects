# relErrLoss <- function(theta){
#   res <- theta *dgamma(theta, 196.5, rate=280)
# }
# integrate(relErrLoss, 0, Inf)



# Section 1====
library(data.table)
library(rjags)
X <-fread('http://www.ics.uci.edu/~mguindan/teaching/stats225/zscores.txt')
p6data <-  list(y = X$V1, N = length(X$V1))
mod <- jags.model("~/Google Drive/CodeProjects/R/p6.bug", data = p6data, n.chains=5, n.adapt = 100)
res <- coda.samples(mod, var = c("y", "mu"), n.iter=1000,thin =10)
summ <- summary(res)
R <- data.frame(as.matrix(res))

sto <- numeric(200)
for(i in 1:200){
  sto[i]<-quantile(R[,i],.5)
}
plot(sto)

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

Z <- weightedBeta(X, 24)
plot(density(Z))
hist(Z)
