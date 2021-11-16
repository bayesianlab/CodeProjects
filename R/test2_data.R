e<- rnorm(100);
x<- runif(100);
y <- 1 + 2.0*x + e 
write.table(y, file="~/y.csv", row.names = FALSE)
write.table(x, file="~/x.csv", row.names = FALSE)
