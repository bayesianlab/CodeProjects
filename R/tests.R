library(truncnorm)
library(mvtnorm)
library(tmvtnorm)



dnorm(.5, -1 , 1)
dnorm(1, -1 , sqrt(2))

dnorm(1,0,sqrt(2), log=TRUE)


dtruncnorm(1, a=0, b=Inf, mean=0.5, sd=1)

dtruncnorm(-.5, a=-Inf, b=0, mean=0.5, sd=1)


log(dtruncnorm(.5, a=0, b=Inf, mean=0.5, sd=2))
-2.4+.8
exp(-1.557)
exp(-1.58)

x <- c(1,1,1)
mu <- c(.5,.5,.5)
Sig <- matrix(c(1, -.3,.09, 
                -.3,1,-.3,
                .09,-0.3,1), nrow=3)

Sig
dmvnorm(x, mu, Sig, log=TRUE)


exp(-3.074)
exp(-3.12)
exp(-6)
exp(0)


ptruncnorm(1, a=0, b=Inf, 0, 1)
ptruncnorm(1, a=0, b=Inf, 1, 1)
ptruncnorm(-1, a=-Inf, b=0, -.5, 1)

1 - ptruncnorm(-0.25, a=0, b=Inf, mean=.25, 1)
x<- seq(-.05, 4, length.out=200)
plot(dtruncnorm(x, a=0, b=Inf, mean=0,1), type='l')
lines(dnorm(x, mean=0,1), type='l')
dnorm(x, mean=0,1)/dtruncnorm(x, a=0, b=Inf, mean=0,1)

vector <- c(2.58221,  2.1817, 3.05775, 2.94566, 1.81817, 5.30992, 4.30884,  2.8966)
mu <- c( 2.4117,1.9915,3.3332,2.78615,1.98806,5.28666,4.24714,2.66056)


vector <- c(2.05284, 3.51118, 4.81545, 2.60319, 2.58416,  3.8233, 1.76955, 3.32193)
mu <- c(2.2699, 3.34161, 4.70334, 2.37269, 2.78593, 3.60878, 1.56935, 3.47421)
s <- diag(c(1, 1, 1, 1, 1, 1, 1, 1))

dmvnorm(vector, mean=mu, sigma=s, log=TRUE)

dtmvnorm(vector, mean=mu, sigma=,lower=rep(0,8), upper=rep(Inf, 8), log=TRUE)

v <- c(0,.5,1)
mu <- c(0,0,0)
ptmvnorm(rep(0,8), rep(Inf, 8),mean=mu, sigma=s)
