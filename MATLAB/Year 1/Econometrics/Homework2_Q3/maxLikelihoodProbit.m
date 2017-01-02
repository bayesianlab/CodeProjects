
function log_like = maxLikelihoodProbit(c,Y,X)
q = 2*Y-1;
probit_F = normcdf(q.*(X*c));
log_like = sum(log(probit_F));
log_like = -log_like;
end

