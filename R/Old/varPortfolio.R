# Variance of Portfolio Returns

varPortfolio <- function(weight1, weight2, sig1, sig2, rho){
  portV <- 0
  portV <- ((weight1^2) * sig1^2 + (weight2^2) * sig2^2 + 
              (2 * weight1 * weight2 * sig1 * sig2 * rho))
  return(portV)
}

expRateReturn <- function(weight1, weight2, rate1, rate2){
  ret <- weight1*rate1 + (1 - weight1)*rate2
  return(ret)
}

pStateCovariance <- function(pstates, data1, data2, mean1, mean2){
  cov <- 0 
  for(i in 1:length(pstates)){
     cov <- cov + pstates[i]*((data1[i] - mean1)*(data2[i] - mean2))
     return(cov)
  }
}

findMin <- function(value, series) {
  epsilon <- .0000001
  for(i in 1:length(series)) {
    if(abs(series[i] - value) < epsilon) {
      return(i)
    } 
  }
}

x <- c(1,4,.39839, -474, 0, -.3) 
xMin <- min(x)
findMin(xMin, x)

