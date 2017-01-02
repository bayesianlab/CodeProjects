library("Hmisc")
x1 <- seq(-10,10)
y1 <- x + 2
x2 <- seq(-10,10)
y2 <- x+1
par(mfrow= c(1,2))
plot(0, 0, xlim= c(-5,5), ylim = c(-5,5), type ="n", axes = F, 
     main = "f", xlab = "x", ylab = "y")
axis(1, pos= c(0,0), at = c(-10:10))
axis(2, pos = c(0,0), at = c(-10:10))
lines(x1,y1)

plot(0, 0, xlim= c(-5,5), ylim = c(-5,5), type ="n", axes = F,
     main = "g", xlab = "x", ylab = "y")
axis(1, pos= c(0,0), at = c(-5:5))
axis(2, pos = c(0,0), at = c(-5:5))
lines(x2,y2)

