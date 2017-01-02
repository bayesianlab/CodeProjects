# Load Data
Data <- read.csv("~/Desktop/Data_PS2a_S15.csv", header=FALSE, sep=",") # Import Data
y <- Data[[1]]
x1 <- Data[[2]]
x2 <- Data[[3]]
x3 <- Data[[4]]
x <- cbind(x1, x2, x3) # create x matrix
# Load packages 
# library("mvtnorm", lib.loc="~/R/win-library/3.2")
# library("mnormt", lib.loc="~/R/win-library/3.2")
# library("coda", lib.loc="~/R/win-library/3.2")
# GLM ---------------------------------------------------------------------

# GLM for beta coefficients, SE's and Hessian
logitY <- glm(y~ x2 + x3, family = "binomial", data = Data)
summary(logitY)
beta <- logitY$coefficients # Beta MLE 
SE <- summary(logitY)$coefficients[,2] # Standard errors 
Hessian <- summary(logitY)$cov.scaled # inverse of the Hessian


# # Proposal Density Variables ----------------------------------------------
# 
# # Define variables to use for Proposal Density in MH Algorithm
# # We will center around maximum likelihood with large tails, so a T distribution
# location1 = unname(beta) # Center it around Beta MLE
# scale1 = unname(Hessian)*30 
# scale2 = unname(SE)
# df = 3 # Fat tails for the T distribution
# 
# # Prior -------------------------------------------------------------------
# 
# # Mean 0 
# mu_prior <- t(c(0,0,0))
# # Variance - Covariance matrix
# sigma_prior = diag(3)*10 
# # Number of Iterations
#  n = 10000
#  
#  
# 
# # Initial Values ----------------------------------------------------------
# 
# plotx <- seq(1,9000,1)
# zeros <- rep(0, times = n)
# beta_c <- matrix(c(zeros, zeros, zeros), nrow = 3)
# beta_p <- matrix(c(zeros, zeros, zeros), nrow = 3)
# 
# # Logistic pdf
# d = 2*y - 1
# 
# 
# # Metropolis Hastings -----------------------------------------------------
# 
# # Acceptance Variable
# acceptn = zeros
# 
# # Procedure
# i <- 1
# while (i<n)  {
#   beta_p[,i] = location1 + scale2*rmvt(1, sigma = scale1*2, df = df) # Generate proposal beta from T distribution beginning at maximum likelihood
#   logit_p = prod(plogis(d*(x%*%beta_p[,i]))) # f(y|B*), plogis is the logistic distribution
#   logit_c = prod(plogis(d*(x%*%beta_c[,i]))) # f(y|B)
#   prior_p = dmvnorm(beta_p[,i], mean = mu_prior, sigma = sigma_prior) # prior for proposal pi(B*)
#   prior_c = dmvnorm(beta_c[,i], mean = mu_prior, sigma = sigma_prior) # prior for current pi(B)
#   proposal_p = dmt(x = beta_p[,i], mean = beta, S = scale1, df = df) #q(B*|y)
#   proposal_c = dmt(x = beta_c[,i], mean = beta, S = scale1, df = df) # q(B|y)
# 
#   a_ratio = (logit_p*prior_p*proposal_c)/(logit_c*prior_c*proposal_p) # ratio for acceptance
#   a_prob = min(1,a_ratio) # probability of acceptance
#   accept = rbinom(1, size = 1, prob = a_prob) #random binomial draw for acceptance
#   
#   if (accept == 1){
#     beta_c[,i+1] = beta_p[,i]
#     acceptn[i] = 1
#   } else {
#       beta_c[,i+1] = beta_c[,i]
#       acceptn[i] = 0
#   }
#   i = i+1
#   
# }
# 
# accept_burn = acceptn[1001:n]
# totalM <- sum(accept_burn)
# a_rate <- totalM/9000 # Acceptance rate
# print(a_rate)
# 
# 
# # Posterior Mean and SD ----------------------------------------------------------
# beta_px1 <- beta_p[1,1001:n] # burn the first thousand
# beta_px2 <- beta_p[2,1001:n]
# beta_px3 <- beta_p[3,1001:n]
# 
# print(mean(beta_px1))
# print(sd(beta_px1))
# print(mean(beta_px2))
# print(sd(beta_px2))
# print(mean(beta_px3))
# print(sd(beta_px3))
# 
# # Plots -------------------------------------------------------------------
# pdf(file = "plot1.pdf")
# hist(beta_px1, breaks = 1000, freq = FALSE, main = "Beta 1", xlab = "Red line = True Beta")
# abline(v = beta[1], col="red")
# dev.off()
# 
# pdf(file = "plot2.pdf")
# hist(beta_px2, breaks = 1000, freq = FALSE, main = "Beta 2", xlab = "Red line = True Beta")
# abline(v = beta[2], col="red")
# dev.off()
# 
# pdf(file = "plot3.pdf")
# hist(beta_px3, breaks = 1000, freq = FALSE, main = "Beta 3", xlab = "Red line = True Beta")
# abline(v = beta[3], col="red")
# dev.off()
# 
# 
# # Marginal Effect ---------------------------------------------------------
# 
# betaPost <- mean(beta_px2)
# xvector <- betaPost * x2
# PiME <- 1/(1+exp(xvector))
# MEffect <- betaPost*PiME*(1-PiME)
# 
# MEffect_mean <- mean(MEffect)
# MEffect_SD <- sd(MEffect)
# print(MEffect_mean)
# print(MEffect_SD)
# 
# pdf(file = "plot4.pdf")
# hist(MEffect, breaks = 1000, freq = FALSE, main = "Marginal Effect Mean", xlab = "Red line = Mean")
# abline(v = MEffect_mean, col="red")
# dev.off()
# 
# pdf(file = "plot5.pdf")
# plot(plotx,beta_c[1,],"l")
# dev.off()
# pdf(file = "plot6.pdf")
# plot(plotx,beta_c[2,],"l")
# dev.off()
# pdf(file = "plot7.pdf")
# plot(plotx,beta_c[3,],"l")
# dev.off()