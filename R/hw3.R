library(ggplot2)
setwd("~/Google Drive/CodeProjects/R/")
data <- as.data.frame(read.table("coal.txt", header=TRUE))
rc <- dim(data)
data <- cbind(data,seq(1,rc[1], by=1))
colnames(data)[3] <- "index"
y <- data$disasters
N <- length(y)
R <- 10
posterior <- data.frame(matrix(0, nrow=R, ncol=3))
cumulativeSumY <- cumsum(y)
thetaRange <- 1:N-1
theta <- sample(thetaRange, 1, replace = TRUE)
alpha <- 3
bn <- 1000
for(i in 1:2000){
  u1 <- sum(y[1:theta]) + 3
  v1 <- (theta + alpha^(-1))^(-1)
  u2 <- sum(y[(theta+1):N]) + 3
  v2 <- (N - theta + alpha^(-1))^(-1)
  lam1 <- rgamma(1, u1, scale=v1)
  lam2 <- rgamma(1, u2, scale=v2)
  unnormalized <- (lam1/lam2)^(cumulativeSumY)*exp(-thetaRange*(lam1-lam2))
  normalized <- unnormalized/sum(unnormalized)
  theta <- which(runif(1) < cumsum(normalized))[1]
  if(i > bn){
    posterior[i,] <- c(lam1, lam2, theta)  
  }
  
}
par(mfrow=c(1,3))
hist(posterior[,1])
hist(posterior[,2])
hist(posterior[,3])
par(mfrow=c(3,1))
plot(posterior[,1], type="l")
plot(posterior[,2], type="l")
plot(posterior[,3], type="l")
par(mfrow=c(1,3))
plot(density(posterior[,1]))
plot(density(posterior[,2]))
plot(density(posterior[,3]))
par(mar=c(1,1,1,1))
q#D@