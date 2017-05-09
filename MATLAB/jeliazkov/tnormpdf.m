function [ tOrdinate] = tnormpdf(a,b,mu,sigma,x )
sigmaZ = sigma.* (normcdf((b-mu)./sigma) - normcdf( (a-mu)./sigma ));
tOrdinate = normpdf((x-mu)./sigma)./sigmaZ;
end

