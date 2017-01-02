# In Class Work on EFN and Growth Rates 
# The first polygon overlaps
# Demonstration how to get the correct polygon by calculating
# intersection point, which is the Internal Growth Rate

projected_sales <- seq(1,30, by = 1)
external_financing <- seq(1, 125)
efnGrowthData <- read.csv("~/R projects/efnGrowthData.csv")
growthInSales <- efnGrowthData[3]
increaseInAssets <- efnGrowthData[2]
addsToRE <- efnGrowthData [1]

x <- cbind(growthInSales, addsToRE)
y <- cbind(growthInSales, increaseInAssets)
plot(y, type = 'l', main = 'Growth and Realted Financing Needs')
lines( x)

#  Estimated polygons

# ycorsLower <- c(0, 44 , 48.40)
# xcorsLower <- c(0, 0, 10)
# ycorsUpp   <- c(48.40, 125, 55.28)
# xcorsUpp   <- c(10, 25, 25)
# trianglecorsLower <- cbind(xcorsLower, ycorsLower)
# trianglecorsUpp   <- cbind(xcorsUpp, ycorsUpp)
# polygon(trianglecorsLower, col= 'blue')
# polygon(trianglecorsUpp, col = 'red')

#  Corrected polygons

ycorsRevised1 <- c(0 ,44, 48.3515)
xcorsRevised1 <- c(0, 0 , 9.67)
ycorsRevised2 <- c(48.3515, 125, 55.28)
xcorsRevised2 <- c(9.67, 25, 25)
triangleCorrected2 <- cbind(xcorsRevised2, ycorsRevised2)
triangleCorrected1 <- cbind(xcorsRevised1, ycorsRevised1)
polygon(triangleCorrected2, col = 'yellow')
polygon(triangleCorrected1, col = 'magenta')


sustainablex = c(0, 0, 9.67, 25, 25)
sustainabley = c(0,44,  48.3515, 125, 55.28)
points(sustainablex, sustainabley, pch = 16)
text(9.67, 48.3515, 'Sustainable Growth', pos = 3)
