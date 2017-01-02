n <- 50
b0 <- 1
b1 <- 1
x <- 1:n
sigma <- 4
e <- rnorm(n, 0, sigma)
y <- b0 + b1*x + e
png(filename = 'r.png', 1800, 800)
plot(x,y, col = 'blue', pch=19, cex= 3)
dev.off()

