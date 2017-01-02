function log_like = logit_likelihood(beta,X,y)
q = 2*y-1;
probit_F = cdf('Logistic',q.*(X*beta));
log_like = sum(log(probit_F));
end

