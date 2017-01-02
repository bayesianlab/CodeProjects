fac <- 880
Y <- seq(0, 3000, by = 1)
Demand = fac + .5*Y
Z <- Y

# Plot dimensions, lines and intersection point with label
plot(1:3000, 1:3000, type = 'n', ylab = "Demand (Z)/ Production (Y)",
     xlab = "Income (Y)", main = "Equilibrium in the Goods Market")
lines(Z)
lines(Demand)
points(880*2, 880*2, pch = 24, bg = "green")
text(880*2, 880*2, "Demand = Supply", pos = 2)