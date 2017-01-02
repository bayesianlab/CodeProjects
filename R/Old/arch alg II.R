# Finding out if a truck will fit through a arch

# Library necessary for the truck image
library(png)

# Function quad computes the quadratic equation determined by coefficients
# and a specific x input and gives the output
quad <- function(a, b, c, x){
  ans <- a*x^2 + b*x + c
  return(ans)
}

# Obtianing lots of inputs and outputs
x <- seq(-10, 25, .5)
y <- numeric(length(x))
for(i in 1:length(x)){
  y[i] <- quad(-.0625, 1.25, 5.75, x[i] )
}

# Getting the truck image from file, R projects truck.png
ima <- readPNG("truck.png")

# Creating a blank blot wiht required x and y limites
plot(0, type = 'n', xlim = c(-10, 30), ylim = c(-1, 12))
# Drawing x, y axis
abline(h = 0)
abline(v = 0, col = "blue")
lines(x, y, type = "l")
# Defining width height and breadth of image
rasterImage(ima, 6.5,0, 13.5, 4 )
text(13.5, 4, labels = "Will it fit?")

# adding interesting lines
abline( v = 20, col = "blue")
abline(v = 6.5, col = "red")
abline(v = 13.5, col = 'red')
abline(h = 11, col = "red")
points(6.5, quad(-.0625, 1.25, 5.75, 6.5), pch = 19, cex = .5)
points(13.5, quad(-.0625, 1.25, 5.75, 13.5), pch = 19, cex = .5)

