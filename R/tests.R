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




v <- c(0.442796, 0.760401, 0.984561)
mu <- c(0, .5, 1)
s <- matrix(c(1, -.7, .49,
        -.7, 1, -.7,
        .49, -.7, 1), nrow=3, ncol=3)

dmvnorm(v, mean=mu, sigma=s, log=TRUE)

dmvnorm(v, mean=mu, sigma=s, log=TRUE)-
dtmvnorm(v, mean=mu, sigma=s,lower=rep(0,3), upper=rep(Inf, 3), log=TRUE)
log(ptmvnorm(mean=mu, sigma=s,lowerx=rep(0,3), upperx=rep(Inf, 3), maxpts=10000))

v <- c(0,.5,1)
mu <- c(0,0,0)
ptmvnorm(rep(0,8), rep(Inf, 8),mean=mu, sigma=s)


exp(-1.58)
exp(-1.557)

z <- c(-8.80411,-8.77264,
-8.77227,
-8.8012,
-8.83201,
-8.78102,
-8.80849,
-8.82589,
-8.77538,
-8.76784)

sd(z)
