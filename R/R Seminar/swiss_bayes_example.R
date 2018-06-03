# Simple Bayesian Regression Example
linRegGibbSampler <- function(y, x, n_sims, burn_in, beta0, B0,
                              tuning_params=c(1,1)){
  row_col <- dim(x)
  all_variables <- row_col[2]
  if(missing(B0)){
    B0 <- diag(all_variables)
  }
  if(missing(beta0)){
    beta0 <- rep(0, row_col[2])
  }
  
  delta0 <- tuning_params[1]
  alpha0 <- tuning_params[2]
  alpha1 <- alpha0 + row_col[1]
  betas <- matrix(nrow = n_sims, ncol = row_col[2])
  sigma2 <- numeric(n_sims)
  sigma2[1] <- 1
  for(s in 2:n_sims){
    inverse_variance <- 1/sigma2[s-1]
    x_prime_x <- t(x) %*% x
    Beta1Next <-  solve(  ( inverse_variance * x_prime_x) + B0 )
    betaBarNext <-  Beta1Next %*% ( ((inverse_variance * t(x)) %*% y) + (B0 %*% beta0) )
    betas[s, 1:all_variables] <- mvrnorm(n=1, mu=betaBarNext, Sigma=Beta1Next)
    residual <- y - (x %*% betas[s, 1:all_variables])
    deltaNext <- (1/2)*(delta0 + t(residual) %*% residual)^-1
    sigma2[s] <- rinvgamma(1, alpha1, deltaNext)
  }
  betas <- betas[burn_in:n_sims, 1:all_variables]
  sigma2 <- sigma2[burn_in:n_sims]
  posteriors <- list(betas, sigma2)
  visualizePosteriorDist(posteriors, all_variables)
  return(posteriors)
  
}

visualizePosteriorDist <- function(posteriors_beta_sigma, covariates){
  betas <- matrix(unlist(posteriors_beta_sigma[1]), ncol=covariates)
  sigmas <- matrix(unlist(posteriors_beta_sigma[2]), ncol=1)
  for(i in 1:covariates){
    print(mean(betas[,i]))
    hist(betas[,i], breaks=10)
  }
  hist(sigmas, breaks=10)
}
