function [ tOrdinate] = tnormpdf(a,b,mu,sigma,x )
Fb = normcdf((b-mu)./sigma);
Fa = normcdf( (a-mu)./sigma );
sx = (x-mu)./sigma;
sigmaZ = sigma.* (Fb - Fa);
tOrdinate = normpdf(sx)./sigmaZ;
end

