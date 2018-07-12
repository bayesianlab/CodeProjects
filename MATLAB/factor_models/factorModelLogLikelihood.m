function [LL] = factorModelLogLikelihood(y, mu, Sigma, a, Sinv)
condvars = diag(inv(Sinv));
[K,T] = size(y);
sigmainv = inv(Sigma);
constant = K*T*log(2*pi);
determinantSum = 0;
mahsum = 0;
prior = logmvnpdf(a,zeros(length(a),1), 10*eye(length(a)));
for t = 1:T
    Vt = Sigma + a*condvars(t)*a';
    innerwood = inv( (1/condvars(t)) + a'*sigmainv*a);
    Woodbury = sigmainv - (sigmainv * a *innerwood*a'*sigmainv);
    determinantSum = determinantSum + log(det(Vt));
    st = (y(:,t) - mu(:,t));
    mahsum = mahsum + st'*Woodbury*st;
end
LL = prior  -.5*(constant + mahsum  + determinantSum);
end

