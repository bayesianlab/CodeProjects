library(sandwich)
read.csv("https://eee.uci.edu/18z/62220/home/wagedata.csv")
# Dummy Variable Reg
N <- 100
x<-1:N+rnorm(N,0,5)
frac1 <- floor(.35*N)
z <- c(rep(1,frac1), rep(0,N-frac1))
y <- 3 + 1.2*x + 2*z  -1.5*x*z + rnorm(100,0,sd=5)
plot(x,y)
plot(z,y)
r1 <- lm(y~x+z + x*z)
summary(r1)

D <- cbind(y,x,z)
D

colnames(D) <- c("Wage", "Ability", "Phd")
D

write.csv(D,file="wagedata.csv", row.names=FALSE)
# Heteroskedasticity 

x<-1:100+rnorm(100,0,10)
z <- c(rep(1,25), rep(0,75))
Het <- rep(1,100)
Het <- c(Het[1:25], Het[26:50]*rep(2,25), Het[51:100]*rep(4,50)) 
y <- 3 + 1.2*x + rnorm(100,0,sd=10)*Het
plot(x,y)
r2 <- lm(y~x+z)
vcov(r2)
sqrt(diag(vcovHC(r2)))
summary(r2)

write.csv(cbind(y,x), file="ec122A.csv")

