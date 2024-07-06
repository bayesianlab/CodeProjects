library(truncnorm)
library(mvtnorm)
dnorm(1, 1 , 1)


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

