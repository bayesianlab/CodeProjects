# Homework 2
source('~/R projects/compare_w_fran.R', echo=TRUE)
DATA <- read.csv("~/Google Drive/UCI/Year_1/Econometrics/Data_PS2a_S15.csv", header=FALSE)
dep = as.matrix(DATA[,1])
X = as.matrix(DATA[ , 2:4])
param = as.matrix(c(1,1,1))
minned_ll = optim(param, logit_log_like, X=X, y=dep, hessian=T)
ests = t(minned_ll[[1]])
hess = minned_ll[6][[1]]
invHess <- solve(hess)
ses = sqrt(diag(invHess))
labs <- c('Const', 'Beta 1', 'Beta 2')
estimates_ses <- rbind(labs, ests, ses)
estimates_ses
# Should be [(est, se)] (1.33, .12), (-0.35, 0.087), (2.24, 0.14)