library(MASS)
library(MCMCpack)
library(base)
library(ggplot2)
library(BLR)
n_sims = 11000
data(swiss)
DATA <- matrix(unlist(swiss), nrow = 47)
head(swiss)
y <- DATA[1:47, 1]
x <- DATA[1:47, 2:6]
regress <- lm(y~x)

# summary(regress)
const <- rep(1,nrow(DATA))
x <- cbind(const, x)
row_col <- dim(x)

betas <- matrix(nrow = n_sims-1, ncol = row_col[2])
sigma2 <- numeric(n_sims)

B0 <- diag(x=1e6, row_col[2])
beta0 <- matrix(c(70, 0, 0, -1, 0, 1), nrow=6)
delta0 <- 20
alpha0 <- 6
alpha1 <- (alpha0+row_col[1])*.5 
sigma2[1] <- 1
x_prime_x <- t(x) %*% x
B0inv <- solve(B0)
pMat <- B0inv %*% beta0 
for(s in 2:n_sims){
  v <- 1/sigma2[s-1]
  Beta1Inv <-  solve( (v*x_prime_x) + B0inv)
  betaBarNext <-  Beta1Inv %*% ( (v*t(x) %*% y) + pMat)
  betas[s-1,] <- mvrnorm(n=1, mu=betaBarNext, Sigma=Beta1Inv)
  residual <- y - (x %*% betas[s-1,])
  delNext <- (delta0 + t(residual)%*%residual)*.5
  sigma2[s] <- rinvgamma( 1, alpha1, delNext) 
}
burn <- as.integer(n_sims*.10)
betas <- betas[(burn+1):n_sims-1,]
sigma2 <- sigma2[(burn+1):n_sims]
coefs <- cbind(betas, sigma2)
postMeans <- colMeans(coefs)
postVars <- apply(coefs, 2, sd)
lb <- apply(coefs, 2, quantile, .05)
ub <- apply(coefs, 2, quantile, .95)
credInts <- data.frame(rbind(postMeans, postVars, ub, lb))
# ggplot(as.data.frame(coefs), aes(coefs[,2])) + 
#   geom_histogram(fill="blue", color="black") +
#   labs(x="Agriculture")
# ggplot(as.data.frame(coefs), aes(coefs[,3])) + 
#   geom_histogram(fill="red",color="black") +
#   labs(x="Examination")
# ggplot(as.data.frame(coefs), aes(coefs[,4])) + 
#   geom_histogram(fill="orange",color="black") +
#   labs(x="Education")
# ggplot(as.data.frame(coefs), aes(coefs[,5])) + 
#   geom_histogram(fill="purple",color="black") +
#   labs(x="Catholic")
# ggplot(as.data.frame(coefs), aes(coefs[,6])) + 
#   geom_histogram(fill="black", color="white") +
#   labs(x="Infant Mortality")
# ggplot(as.data.frame(coefs), aes(coefs[,7])) +
#   geom_histogram(fill="green",color="black") +
#   xlab(expression(symbol(sigma^2)))

b0 <- matrix(c(66, -.17, -.25, -.87, .1041, 1.074), nrow=6)
b0X <- matrix(c(66, -.17, -.25), nrow=3)
B0X <- diag(1, 3)
breg <- MCMCregress(Fertility ~ Agriculture + Examination + Education + Catholic + Infant.Mortality, 
                    b0=b0, B0=B0, c0=6, d0=10, data=swiss, marginal.likelihood = "Chib95")
bregX <- MCMCregress(Fertility ~ Agriculture + Examination, data=swiss, 
                     b0=b0X, B0=B0X, c0=6, d0=20,marginal.likelihood = "Chib95")
bf <- BayesFactor(breg, bregX)
print(bf)

head(birthwt)
c <- lm(bwt~age +lwt+as.factor(race)+smoke, data=birthwt)
sum(c$residuals^2)
# breg <- MCMCregress(Fertility ~ Agriculture + Examination + 
#                                     Education + Catholic + Infant.Mortality, data=swiss)

# plot(breg)
# par("mar")
# par(mar=c(1,1,1,1))
# library(coda)
# breg$
# var(regress$residuals)

rownames(credInts) <- c("Post.Mean", "Post.SDs", "95%", "5%")
names <- c("constant", colnames(swiss)[2:6], "sigma2")
colnames(credInts)[1:7] <- names
credInts
summary(breg)

data(birthwt)

linm <- lm(bwt~age+lwt+as.factor(race) + smoke + ht, data=birthwt)
summary(linm)

model0 <- MCMCregress(bwt~lwt+as.factor(race) + smoke + ht,
                      data=birthwt, b0=c(0, 0, -500, -500,
                                         -500, -500),
                      B0=c(.01, .01, 1.6e-5, 1.6e-5, 1.6e-5,
                           1.6e-5), c0=10, d0=4500000,
                      marginal.likelihood="Chib95", mcmc=10000)
BayesFactor(model1, model0)


model1 <- MCMCregress(bwt~age+lwt+as.factor(race) + smoke + ht,
                      data=birthwt, b0=c(2700, 0, 0, -500, -500,
                                         -500, -500),
                      B0=c(1e-6, .01, .01, 1.6e-5, 1.6e-5, 1.6e-5,
                           1.6e-5), c0=10, d0=4500000,
                      marginal.likelihood="Chib95", mcmc=10000)

model2 <- MCMCregress(bwt~age+lwt+as.factor(race) + smoke,
                      data=birthwt, b0=c(2700, 0, 0, -500, -500,
                                         -500),
                      B0=c(1e-6, .01, .01, 1.6e-5, 1.6e-5, 1.6e-5),
                      c0=10, d0=4500000,
                      marginal.likelihood="Chib95", mcmc=10000)

model3 <- MCMCregress(bwt~as.factor(race) + smoke + ht,
                      data=birthwt, b0=c(2700, -500, -500,
                                         -500, -500),
                      B0=c(1e-6, 1.6e-5, 1.6e-5, 1.6e-5,
                           1.6e-5), c0=10, d0=4500000,
                      marginal.likelihood="Chib95", mcmc=10000)

BF <- BayesFactor(model1, model2, model3)
print(BF)

head(birthwt)
bf <- regressionBF(bwt~age+lwt+race+ smoke + ht, data=birthwt, whichModels="bottom")
plot(bf)
