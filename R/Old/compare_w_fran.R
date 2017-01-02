logit_log_like <- function(beta, X, y){
  q = 2*y - 1 
  xTimesb = X %*% beta
  prob = plogis(q * xTimesb)
  log_like = sum( log(prob) )
  return(-log_like)
}


# Estimates of Logit, with standard errors


# library(MASS)
# library(mvtnorm)
# Sigma <- invHess
# MH_binary_logit <- function(nsims=10, X, y) {
#   for(i in 1:nsims){
#     proposalBeta <- ests + rmvt(1, Sigma, df=10)
#     numerator <- logit_log_like(proposalBeta, X,y )*
#       dmvnorm(proposalBeta, c(0,0,0),)
#   }
# }
# MH_binary_logit(nsims=10)
# 
# randT <- ests + rmvt(1, Sigma, df=10)



