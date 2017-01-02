# gamma function
mygammadist <- function(x, a, b){
  c <- (gamma(a)/b^a)
  rv <- ( x^(a-1) ) * ( exp(-(x/b) ) ) 
  gammaVal <- rv*c
  return(gammaVal)
}

set.seed(1.1)
rinvgamma(1,4,5)
rigamma(1,4,5)