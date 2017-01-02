x <- c(19,13,17,18,20,14)
ai <- 2
beta <- ai*(length(x)-1) + sum(x) - x[1] - 1
alpha <- x[1] + ai - 1
theta1 <- seq(0,1, length=100)
sto <- numeric(length(theta1))
for(i in 1:length(theta1)){
  sto[i] <- dbeta(theta1[i], alpha, beta)
}
plot(theta1, sto, type ='l')
mBeta1 = alpha/(alpha+beta)
abline(v=mBeta1)


x <- 10*c(19,13,17,18,20,14)
ai <- 2
beta <- ai*(length(x) -1) + sum(x) - x[1] - 1
alpha <- x[1] + ai - 1
theta1 <- seq(0,1, length=51)
sto <- numeric(length(theta1))
for(i in 1:length(theta1)){
  sto[i] <- dbeta(theta1[i], alpha, beta)
}
plot(theta1, sto, type ='l')
mBeta2 = alpha/ (alpha+beta)
abline(v= mBeta2)
