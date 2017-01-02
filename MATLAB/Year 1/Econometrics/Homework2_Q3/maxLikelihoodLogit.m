function log_like = maxLikelihoodLogit(c,X,y)
q = 2*y-1;
probit_F = cdf('Logistic',q.*(X*c));
log_like = sum(log(probit_F));
log_like = -log_like;
end
