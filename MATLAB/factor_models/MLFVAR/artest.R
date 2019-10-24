rtest <- read_csv("CodeProjects/MATLAB/factor_models/MLFVAR/rtest.csv", 
                       col_names = FALSE)
x<-rnorm(100)
y <- 1 + x*1 + rnorm(100)
n <- data.frame(y,x)
lm(n$y~n$x)
