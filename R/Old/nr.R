
yield <- function(r){
  y <- (20*exp(-r * .5)) + (20 *exp(-r)) + (20 * exp(-r*1.5)) + (1020*exp(-r*2)) - 1015
  y
}
dyield <- function(r){
  y <- (-10*exp(-r*.5)) - (20 * exp(-r)) - (30*exp(-r*1.5)) - (2040*exp(-r*2))
  y
}

nr <- function(g){
  eps <- 10^(-4)
  for(i in 1:20){
    yNext <- g - (yield(g/100) / dyield(g/100))
    g <- yNext
    cat(sprintf('converging to zero %f\n',yield(g)))
  }
}



x <- numeric(0)
for(i in 1:400){
  x[i] <- yield(i)
}
plot(1:400, x, type='l', ylim=c(-10, 10))

